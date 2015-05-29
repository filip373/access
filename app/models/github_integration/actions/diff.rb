module GithubIntegration
  module Actions
    class Diff
      include Celluloid

      attr_reader :errors

      def initialize(expected_teams, gh_teams, gh_api)
        @expected_teams = expected_teams
        @gh_teams = gh_teams
        @gh_api = gh_api
        @errors = []
        @total_diff_condition = Celluloid::Condition.new
      end

      def now!
        generate_diff
        @condition.wait
      end

      private

      def generate_diff
        @expected_teams.each do |expected_team|
          gh_team = find_or_create_gh_team(expected_team)
          TeamDiff.new(expected_team, gh_team, @gh_api, @diff_hash, blk).async.diff
        end
      end

      def gh_team(team_name)
        @gh_teams.find { |t| t.name.downcase == team_name.downcase }
      end
    end
  end
end
