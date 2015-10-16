module GithubIntegration
  class Team
    rattr_initialize :name, :members, :repos, :permission

    def self.from_api_request(client, team)
      new(
        team.name,
        api_team_members(client, team),
        api_team_repos(client, team),
        team.permission,
      )
    end

    def self.from_storage(team)
      new(
        team.id,
        team.members,
        team.repos,
        team.permission,
      )
    end

    def to_h
      {
        name: name,
        members: members,
        repos: repos,
        permission: permission,
      }
    end

    def to_yaml
      {
        permission: permission,
        members: members || [],
        repos: repos || [],
      }.stringify_keys.to_yaml
    end

    def self.api_team_members(client, team)
      client.list_team_members(team.id).map(&:login)
    end
    private_class_method :api_team_members

    def self.api_team_repos(client, team)
      client.list_team_repos(team.id).map(&:name).uniq
    end
    private_class_method :api_team_repos
  end
end
