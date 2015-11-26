module TogglIntegration
  class Team
    attr_reader :name, :members, :projects, :tasks, :id

    def initialize(name:, members:, projects:, tasks:, id:)
      @name = name
      @members = members
      @projects = projects
      @tasks = tasks
      @id = id
    end

    def to_yaml
      {
        name: name,
        members: members.map(&:id).select(&:present?) || [],
        tasks: tasks || [],
        projects: projects || [],
      }.stringify_keys.to_yaml
    end
  end
end
