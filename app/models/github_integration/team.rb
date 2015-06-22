module GithubIntegration
  class Team
    rattr_initialize :name, :members, :repos, :permission

    def self.from_api_request(client, team)
      new(
        team.name,
        client.list_team_members(team.id).map(&:login),
        client.list_team_repos(team.id).map(&:name).uniq,
        team.permission,
      )
    end
  end
end
