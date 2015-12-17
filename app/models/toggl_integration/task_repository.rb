module TogglIntegration
  class TaskRepository
    attr_reader :all

    def initialize(all: [])
      @all = all
    end

    def self.build_from_toggl_api(toggl_api)
      tasks = toggl_api.list_teams.flat_map do |team|
        toggl_api.list_all_tasks(team['id']).map do |task|
          Task.new(id: task['id'], name: task['name'], pid: task['pid'], wid: task['wid'])
        end
      end
      new(all: tasks)
    end
  end
end
