module TogglIntegration
  class TaskRepository
    attr_reader :all

    def initialize(all: [])
      @all = all
    end

    def self.build_from_toggl_api(toggl_api)
      toggl_api.list_teams.each do |team|
        tasks = toggl_api.list_all_tasks(team.id).map do |task|
          Task.new(name: task['name'], pid: task['pid'])
        end
      end
      new(all: tasks)
    end
  end
end
