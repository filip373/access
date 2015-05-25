module GithubIntegration
  module Actions
    class Diff
      include Celluloid

      def initialize(expected_teams, gh_teams, gh_api)
        @expected_teams = expected_teams
        @gh_teams = gh_teams
        @gh_api = gh_api
        @diff_hash = {
          create_teams: {},
          add_members: {},
          remove_members: {},
          add_repos: {},
          remove_repos: {},
          change_permissions: {},
        }
      end

      def now!
        generate_diff
        @condition = Celluloid::Condition.new
        wait_diff_result = @condition.wait
        wait_diff_result
      end

      private

      def generate_diff
        diffed_count = 0
        @expected_teams.each do |expected_team|
          blk = lambda do |diff|
            diffed_count += 1
            @condition.signal(diff) if diffed_count == @expected_teams.size
          end
          gh_team = find_or_create_gh_team(expected_team)
          TeamDiff.new(expected_team, gh_team, @gh_api, @diff_hash, blk).async.diff
        end
      end

      def get_gh_team(team_name)
        @gh_teams.find { |t| t.name.downcase == team_name.downcase }
      end

      def find_or_create_gh_team(expected_team)
        team = get_gh_team(expected_team.name)
        return team unless team.nil?
        @diff_hash[:create_teams][expected_team] = {}
        expected_team
      end
    end
  end
end
