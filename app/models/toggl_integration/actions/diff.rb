module TogglIntegration
  module Actions
    class Diff
      attr_reader :local_teams, :current_teams, :errors, :toggl_members_repo,
                  :user_repo, :toggl_tasks_repo

      def initialize(local_teams, current_teams, user_repo, toggl_members_repo, toggl_tasks_repo)
        @local_teams = local_teams
        @current_teams = current_teams
        @toggl_members_repo = toggl_members_repo
        @toggl_tasks_repo = toggl_tasks_repo
        @user_repo = user_repo
        @errors = []
      end

      def call
        reset_diff_hash
        find_members_without_permissions
        diff_teams
        diff_hash
      end

      def diff_hash
        @diff_hash ||= {
          create_teams: {},
          add_members: {},
          remove_members: {},
          missing_teams: [],
          deactivate_members: Set.new,
          create_tasks: {},
          remove_tasks: {},
        }
      end

      private

      def normalize_members(*members)
        result = []
        members.each do |member|
          if member.emails.empty?
            @errors << "User #{member.id} has no email."
            next
          end
          toggl_member = toggl_members_repo.find_by_emails(*member.emails)
          result << (toggl_member.nil? ? member : toggl_member)
        end
        result
      end

      def normalize_tasks(*tasks)
        result = []
        tasks.each do |task|
          if task.name.empty?
            @errors << "Task #{task.id} has no name."
            next
          end
          if task.pid.empty?
            @errors << "Task #{task.id} has no project id."
            next
          end
          result << task
        end
        result
      end

      def diff_teams
        server_teams = current_teams.dup
        local_teams.each do |local_team|
          server_team = server_teams.find { |st| st.name.downcase == local_team.name.downcase }
          if server_team
            diff_teams_members(local_team, server_team)
            diff_teams_tasks(local_team, server_team)
            server_teams.delete(server_team)
          else
            diff_hash_array(:create_teams, local_team).concat normalize_members(*local_team.members)
            diff_hash_array(:create_tasks, local_team).concat normalize_tasks(*local_team.tasks)
          end
        end
        diff_hash[:missing_teams].concat server_teams if server_teams.any?
      end

      def diff_teams_members(local_team, server_team)
        return unless local_team.name == server_team.name
        server_team_members = server_team.members.dup
        local_team.members.each do |local_member|
          server_member = server_team_members.find { |sm| (sm.emails & local_member.emails).any? }
          if server_member
            server_team_members.delete(server_member)
          else
            diff_hash_array(:add_members, server_team).concat normalize_members(local_member)
          end
        end
        diff_hash_array(:remove_members, server_team)
          .concat server_team_members if server_team_members.any?
      end

      def diff_teams_tasks(local_team, server_team)
        return unless local_team.name == server_team.name
        server_team_tasks = server_team.tasks.dup
        local_team.tasks.each do |local_task|
          server_task = server_team_tasks.find { |st| st.name == local_task.name }
          if server_task
            server_team_tasks.delete(server_task)
          else
            diff_hash_array(:create_tasks, server_team).concat normalize_tasks(local_task)
          end
        end
        diff_hash_array(:remove_tasks, server_team)
          .concat server_team_tasks if server_team_tasks.any?
      end

      def diff_hash_array(group, team)
        diff_hash[group][team] ||= []
      end

      def reset_diff_hash
        @diff_hash = nil
      end

      def find_members_without_permissions
        @toggl_members_repo.all.select(&:active?).each do |member|
          user = begin
                   @user_repo.find_by_email(member.default_email)
                 rescue
                   nil
                 end
          if user
            unless has_team_assigned?(user)
              @errors << "User #{member.default_email} has no team assigned."
            end
          else
            diff_hash[:deactivate_members] << member
          end
        end
      end

      def has_team_assigned?(member)
        local_teams.each do |team|
          return true if team.members.any? { |m| m.id == member.id }
        end
        false
      end
    end
  end
end
