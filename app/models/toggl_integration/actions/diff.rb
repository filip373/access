module TogglIntegration
  module Actions
    class Diff
      attr_reader :local_teams, :current_teams, :errors, :toggl_members_repo, :user_repo

      def initialize(local_teams, current_teams, user_repo, toggl_members_repo)
        @local_teams = local_teams
        @current_teams = current_teams
        @toggl_members_repo = toggl_members_repo
        @user_repo = user_repo
        @errors = []
      end

      def call
        reset_diff_hash
        diff_teams
        find_members_without_permissions
        diff_hash
      end

      def diff_hash
        @diff_hash ||= {
          create_teams: {},
          add_members: {},
          remove_members: {},
          missing_teams: [],
          deactivate_members: Set.new,
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

      def diff_teams
        server_teams = current_teams.dup
        local_teams.each do |local_team|
          server_team = server_teams.find { |st| st.name.downcase == local_team.name.downcase }
          if server_team
            diff_teams_members(local_team, server_team)
            server_teams.delete(server_team)
          else
            diff_hash_array(:create_teams, local_team).concat normalize_members(*local_team.members)
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
        if server_team_members.any?
          diff_hash_array(:remove_members, server_team).concat server_team_members
        end
      end

      def diff_hash_array(group, team)
        diff_hash[group][team] ||= []
      end

      def reset_diff_hash
        @diff_hash = nil
      end

      def find_members_without_permissions
        @toggl_members_repo.all.each do |member|
          user = @user_repo.find_by_email(member.default_email) rescue nil
          diff_hash[:deactivate_members] << member unless user
        end
      end
    end
  end
end
