module TogglIntegration
  module Actions
    class CleanupTeams
      rattr_initialize :server_teams, :toggl_api

      def call
        server_teams.each { |team| toggl_api.deactivate_team(team.id) }
      end
    end
  end
end
