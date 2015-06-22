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

    def to_yaml
      {
        permission: permission,
        members: members || [],
        repos: repos || [],
      }.stringify_keys.to_yaml
    end
  end
end
