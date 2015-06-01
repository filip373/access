module GithubIntegration
  module Actions
    class Diff
      include Celluloid
      include Celluloid::Notifications

      attr_reader :errors

      def initialize(expected_teams, gh_teams, gh_api)
        @expected_teams = expected_teams
        @gh_teams = gh_teams
        @gh_api = gh_api
        @total_diff_condition = Celluloid::Condition.new
        Observers::TeamDiffObserver.new(
          @total_diff_condition, @expected_teams.size
        ).subscribe 'completed', :on_completion
      end

      def now!
        generate_diff
      end

      private

      def generate_diff
        @expected_teams.each do |expected_team|
          Rollbar.info('generate_diff', expected_team: expected_team)
          gh_team = gh_team(expected_team.name)
          team_diff = TeamDiff.new(expected_team, gh_team, @gh_api)
          team_diff.async.diff
        end
        diff, @errors = @total_diff_condition.wait # Wait till all pools (threads) are done
        Rollbar.info('after condition waiter', diff: diff, errors: @errors)
        @errors.uniq!
        diff
      end

      def gh_team(team_name)
        @gh_teams.find { |t| t.name.downcase == team_name.downcase }
      end
    end
  end
end
