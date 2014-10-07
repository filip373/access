module GithubIntegration
  module Actions
    class SyncTeams < Struct.new(:expected_teams, :gh_api)

      def now!
        sync_members
      end

      def dry_run!
        gh_api.dry_run = true
        sync_members
      end

      def sync_members

        expected_teams.each do |expected_team|
          members = map_users_to_members(expected_team.members)

          gh_team = find_or_create_gh_team(expected_team)
          gh_api.sync_members(gh_team, members)
          gh_api.sync_repos(gh_team, expected_team.repos)
          gh_api.sync_team_permission(gh_team, expected_team.permission)
        end
      end

      private

      def find_or_create_gh_team(expected_team)
        gh_api.get_team(expected_team.name) || gh_api.create_team(expected_team.name, expected_team.permission)
      end

      def map_users_to_members(members)
        members.map { |m|
          user = User.find(m)
          raise "Uknown user #{m}" if user.nil?
          user.github
        }
      end

    end
  end
end
