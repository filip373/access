module GithubIntegration
  class Team
    attr_accessor :name, :members, :repos, :permission, :id
    def initialize(name:, members:, repos:, permission:, id: nil)
      self.name = name
      self.members = members
      self.repos = repos
      self.permission = permission
      self.id = id
    end

    def self.from_api_request(client, team)
      new(
        name: team['name'],
        members: api_team_members(client, team['id']),
        repos: api_team_repos(client, team['id']),
        permission: team['permission'],
        id: team['id'],
      )
    end

    def self.from_storage(team)
      new(
        name: team.id,
        members: team.members,
        repos: team.repos,
        permission: team.permission,
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

    def self.api_team_members(client, team_id)
      client.list_team_members(team_id).map { |member| member['login'] }
    end
    private_class_method :api_team_members

    def self.api_team_repos(client, team_id)
      client.list_team_repos(team_id).map { |repo| repo['name'] }.uniq
    end
    private_class_method :api_team_repos
  end
end
