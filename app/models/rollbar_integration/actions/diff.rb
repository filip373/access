module RollbarIntegration
  module Actions
    class Diff
      include Celluloid

      attr_reader :errors
      def initialize(dataguru_teams, rollbar_teams, user_repo)
        @dataguru_teams = dataguru_teams
        @rollbar_teams = rollbar_teams
        @diff_hash = {
          create_teams: {},
          add_members: {},
          remove_members: {},
          add_projects: {},
          remove_projects: {}
        }
        @errors = []
        @repo = user_repo
        @total_diff_condition = Celluloid::Condition.new
      end

      def now!
        generate_diff
      end

      private

      def generate_diff
        @dataguru_teams.each do |dataguru_team|
          blk = lambda do |diff, errors|
            @errors.push(*errors)
            @total_diff_condition.signal(diff) if all_team_diffs_finished?
          end
          rollbar_team = @rollbar_teams.find { |t| t.name.downcase == dataguru_team.name.downcase }
          team_diff = TeamDiff.new(dataguru_team, rollbar_team, @diff_hash, @repo)
          team_diff.async.diff(blk)
        end
        @total_diff_condition.wait
      end

      def all_team_diffs_finished?
        @diffed_count ||= 0
        @diffed_count += 1
        @diffed_count == @dataguru_teams.size
      end
    end
  end
end
