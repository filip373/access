module GithubIntegration
  module Actions
    class CleanupTeams

      attr_accessor :expected_teams, :gh_api

      def initialize(expected_teams, gh_api)
        self.expected_teams = expected_teams
        self.gh_api = gh_api
      end

      def now!
        remove_stranded_teams
      end

      def stranded_teams
        gh_teams = gh_api.teams
        expected_names = expected_teams.map(&:name)
        gh_teams.reject{ |e| e.name.in?(expected_names) }
      end

      private

      def remove_stranded_teams
        stranded_teams.each do |team|
          gh_api.remove_team(team)
        end
      end
    end
  end
end
