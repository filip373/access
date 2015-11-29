module TogglIntegration
  class TaskRepository
    attr_reader :all

    def initialize(all: [])
      @all = all
    end

    def self.build_from_toggl_api(toggl_api, project_id)
      tasks = toggl_api.get_project_tasks(project_id).map do |task|
        Task.new(name: task['name'], pid: task['pid'])
      end
      new(all: tasks)
    end
  end
end
