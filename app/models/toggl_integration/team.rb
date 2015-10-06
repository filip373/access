module TogglIntegration
  class Team
    rattr_initialize :name, :members, :projects

    def self.from_api_request(api, team)
      new(team['name'],
          team_members(api, team),
          team_projects(team),
         )
    end

    def to_yaml
      {
        name: name,
        members: members || [],
        projects: projects || [],
      }.stringify_keys.to_yaml
    end

    def self.team_members(api, team)
      api.list_team_members(team['id']).map do |member|
        begin
          User.find_by_email(member['email']).id
        rescue
        end
      end.compact
    end

    def self.team_projects(team)
      [team['name']]
    end

    private_class_method :team_members, :team_projects
  end
end
