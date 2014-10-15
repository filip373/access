module GithubIntegration
  module Actions
    class CleanupTeams < Struct.new(:expected_teams, :gh_api)

      def now!
        gh_api.dry_run = true
        remove_stranded_teams
      end

      def dry_run!
        gh_api.dry_run = true
        remove_stranded_teams
      end

      def remove_stranded_teams
        stranded_teams.each do |team|
          gh_api.remove_team(team)
        end
      end

      def stranded_teams
        gh_teams = gh_api.teams
        expected_names = expected_teams.map(&:name)
        gh_teams.reject{|e| e.name.in?(expected_names) }
      end

    end
  end
end
