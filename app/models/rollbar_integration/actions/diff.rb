module RollbarIntegration
  module Actions
    class Diff
      include Celluloid

      attr_reader :errors

      def initialize(yaml_teams, server_teams, rollbar_api)
        @yaml_teams = yaml_teams
        @server_teams = server_teams
        @rollbar_api = rollbar_api
        @diff_hash = {
          create_teams: {},
          add_members: {},
          remove_members: {},
          add_projects: {},
          remove_projects: {},
        }
        @errors = []
        @total_diff_condition = Celluloid::Condition.new
      end

      def now!
        generate_diff
      end

      private

      def generate_diff
        @yaml_teams.each do |yaml_team|
          blk = lambda do |diff, errors|
            @errors.push(*errors)
            @total_diff_condition.signal(diff) if all_team_diffs_finished?
          end
          server_team = server_team(yaml_team.name)
          team_diff = TeamDiff.new(yaml_team, server_team, @rollbar_api, @diff_hash)
          team_diff.async.diff(blk)
        end
        @total_diff_condition.wait # Wait till all pools (threads) are done
      end

      def server_team(team_name)
        @server_teams.find { |t| t.name.downcase == team_name.downcase }
      end

      def all_team_diffs_finished?
        @diffed_count ||= 0
        @diffed_count += 1
        @diffed_count == @yaml_teams.size
      end
    end
  end
end
