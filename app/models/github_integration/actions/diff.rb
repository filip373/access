module GithubIntegration
  module Actions
    class Diff
      include Celluloid

      attr_reader :errors

      def initialize(expected_teams, gh_teams, gh_api, user_repo)
        @expected_teams = expected_teams
        @gh_teams = gh_teams
        @gh_api = gh_api
        @diff_hash = empty_diff_hash
        @errors = []
        @repo = user_repo
        @total_diff_condition = Celluloid::Condition.new
      end

      def now!
        generate_diff
      end

      private

      def empty_diff_hash
        {
          create_teams: {},
          add_members: {},
          remove_members: {},
          add_repos: {},
          remove_repos: {},
          change_permissions: {},
        }
      end

      def generate_diff
        @expected_teams.each do |expected_team|
          blk = lambda do |diff, errors|
            @errors.push(*errors)
            @total_diff_condition.signal(diff) if all_team_diffs_finished?
          end
          gh_expected_team = gh_team(expected_team.name)
          team_diff = TeamDiff.new(expected_team, gh_expected_team, @gh_api, @diff_hash, @repo)
          team_diff.async.diff(blk)
        end
        @total_diff_condition.wait # Wait till all pools (threads) are done
      end

      def gh_team(team_name)
        @gh_teams.find { |t| t.name.downcase == team_name.downcase }
      end

      def all_team_diffs_finished?
        @diffed_count ||= 0
        @diffed_count += 1
        @diffed_count == @expected_teams.size
      end
    end
  end
end
