module GithubIntegration
  module Actions
    class GetTeamsWithAssoc
      pattr_initialize :client

      def now!
        list_teams
      end

      private

      def list_teams
        client.list_teams.map do |team|
          team['members'] = client.list_team_members(team['id']).map { |m| m['login'].downcase }
          team['repos'] = client.list_team_repos(team['id']).map { |r| r['name'].downcase }
          team
        end
      end
    end
  end
end
