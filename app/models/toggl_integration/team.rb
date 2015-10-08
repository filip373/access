module TogglIntegration
  class Team
    attr_reader :name, :members, :projects, :id

    def initialize(name, members, projects, id = nil)
      @name = name
      @members = members
      @projects = projects
      @id = id
    end

    def self.from_api_request(api, team)
      new(team['name'],
          team_members(api, team),
          team_projects(team),
          team['id']
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
          UserRepository.new.find_by_email(member['email']).id
        rescue
          nil
        end
      end.compact
    end

    def self.team_projects(team)
      [team['name']]
    end

    private_class_method :team_members, :team_projects
  end
end
