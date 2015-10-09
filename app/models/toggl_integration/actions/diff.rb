module TogglIntegration
  module Actions
    class Diff
      attr_reader :local_teams, :current_teams, :errors, :local_members_repo, :toggl_members_repo

      def initialize(local_teams, current_teams, local_members_repo, toggl_members_repo)
        @local_teams = local_teams
        @current_teams = current_teams
        @local_members_repo = local_members_repo
        @toggl_members_repo = toggl_members_repo
        @errors = []
      end

      def call
        reset_diff_hash
        diff_teams
        diff_hash
      end

      def diff_hash
        @diff_hash ||= {
          create_teams: {},
          add_members: {},
          remove_members: {},
          missing_teams: [],
        }
      end

      private

      def toggl_members_from_repo_id(*repo_ids)
        members = []
        repo_ids.each do |repo_id|
          repo_member = local_members_repo.find_by_repo_id(repo_id)
          unless repo_member
            @errors << "User #{repo_id} was not found in repository."
            next
          end
          toggl_member = toggl_members_repo.find_by_emails(*repo_member.emails)
          unless toggl_member
            @errors << "User #{repo_id} has no account in Toggle app."
            next
          end
          members << toggl_member
        end
        members
      end

      def toggl_members_from_email(*emails)
        members = []
        emails.each do |email|
          toggl_member = toggl_members_repo.find_by_emails(email)
          unless toggl_member
            @errors << "User with email #{email} has no account in Toggle app."
            next
          end
          members << toggl_member
        end
        members
      end

      def diff_teams
        server_teams = current_teams.dup
        local_teams.each do |local_team|
          server_team = server_teams.find { |st| st.name.downcase == local_team.name.downcase }
          if server_team
            diff_teams_members(local_team, server_team)
            server_teams.delete(server_team)
          else
            diff_hash_array(:create_teams, local_team).concat(
              toggl_members_from_repo_id(*local_team.members))
          end
        end
        diff_hash[:missing_teams].concat server_teams if server_teams.any?
      end

      def diff_teams_members(local_team, server_team)
        return unless local_team.name == server_team.name
        server_team_members = toggl_members_from_email(*server_team.members)
        local_team_members = toggl_members_from_repo_id(*local_team.members)

        local_team_members.each do |local_member|
          server_member = server_team_members.find { |sm| (sm.emails & local_member.emails).any? }
          if server_member
            server_team_members.delete(server_member)
          else
            diff_hash_array(:add_members, server_team) << local_member
          end
        end
        if server_team_members.any?
          diff_hash_array(:remove_members, server_team).concat(server_team_members)
        end
      end

      def diff_hash_array(group, team)
        diff_hash[group][team] ||= []
      end

      def reset_diff_hash
        @diff_hash = nil
      end
    end
  end
end
