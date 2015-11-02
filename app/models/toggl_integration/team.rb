module TogglIntegration
  class Team
    attr_reader :name, :members, :projects, :id

    def initialize(name, members, projects, id = nil)
      @name = name
      @members = members
      @projects = projects
      @id = id
    end

    def to_yaml
      {
        name: name,
        members: members.map(&:id).select(&:present?) || [],
        projects: projects || [],
      }.stringify_keys.to_yaml
    end
  end
end
