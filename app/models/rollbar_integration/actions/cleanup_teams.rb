module RollbarIntegration
  module Actions
    class CleanupTeams
      rattr_initialize :expected_teams, :server_teams, :rollbar_api

      def now!
        remove_stranded_teams
      end

      def stranded_teams
        expected_names = expected_teams.map(&:name)
        server_teams.reject { |e| e.name.in?(expected_names) }
      end

      private

      def remove_stranded_teams
        stranded_teams.each do |team|
          rollbar_api.remove_team(team)
        end
      end
    end
  end
end
