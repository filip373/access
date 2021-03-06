module TogglIntegration
  class Api
    ProjectUser = Struct.new(:id, :uid)
    THREAD_POOL_SIZE = 10

    attr_reader :toggl_client, :company_name

    def initialize(token, company_name)
      @toggl_client = TogglV8::API.new(token)
      @company_name = company_name
      @token = token
    end

    def namespace
      @namespace ||= :toggl
    end

    def list_teams(preload_members: true)
      @teams ||= toggl_client.projects(workspace['id'], active: true)
      return @teams unless preload_members
      team_ids = @teams.map { |team| team['id'] }
      preload_projects_users_with_tasks(team_ids)
      @teams
    end

    def list_all_members
      @workspace_users ||= toggl_client.workspace_users(workspace['id'])
    end

    def list_team_members(team_id)
      list_projects_users(team_id)
        .map { |project_user| member_by_uid(project_user.uid) }
    end

    # name of the method was chosen here to keep compatible
    # with a convention used in this file
    def list_all_tasks(id)
      list_projects_tasks(id)
    end

    def deactivate_team(team_id)
      params = { 'active' => false }
      toggl_client.update_project(team_id, params)
    end

    def add_member_to_team(member, team)
      user = list_projects_users(team.id).find { |u| u['uid'] == member.toggl_id }
      if user
        activate_member(member.toggl_id)
      else
        params = { 'uid' => member.toggl_id, 'pid' => team.id }
        toggl_client.create_project_user(params)
      end
    end

    def remove_member_from_team(member, team)
      project_users = list_projects_users(team.id)
      project_user_id = project_users.find { |pu| pu.uid == member.toggl_id }.id
      toggl_client.delete_project_user(project_user_id)
    end

    def add_task_to_project(task_name, project_id)
      params = { name: task_name, pid: project_id, wid: workspace['id'] }
      toggl_client.create_task(params.stringify_keys)
    end

    def remove_tasks_from_project(tasks_ids)
      toggl_client.update_tasks(tasks_ids, active: false) if tasks_ids.any?
    end

    def invite_member(member)
      toggl_client.invite_member(workspace['id'], member.default_email)
    end

    def deactivate_member(member)
      workspace_user = list_all_members.find { |m| m['uid'] == member.toggl_id }
      return workspace_user if workspace_user['inactive']
      params = { 'inactive' => true }
      toggl_client.update_workspace_user(workspace_user['id'], params)
    end

    def create_team(team)
      params = { 'name' => team.name, 'wid' => workspace['id'] }
      toggl_client.create_project(params)
    end

    def workspace
      @workspace ||= toggl_client.workspaces.find { |w| w['name'] == company_name }
    end

    def list_projects_tasks(team_id)
      if projects_tasks.key?(team_id)
        projects_tasks[team_id]
      else
        projects_tasks[team_id] = safe_fetch do
          toggl_client.get_project_tasks(team_id)
        end
      end
    end

    def list_projects_users(team_id)
      if projects_users.key?(team_id)
        projects_users[team_id]
      else
        projects_users = safe_fetch do
          toggl_client.get_project_users(team_id)
        end
        projects_users[team_id] = projects_users.each_with_object([]) do |pu, users|
          users << ProjectUser.new(pu['id'], pu['uid'])
        end
      end
    end

    private

    def safe_fetch
      tries ||= 10
      yield
    rescue RuntimeError => e
      if e.message.include?('429') && !(tries -= 1).zero? # too many requests
        sleep 1
        retry
      else
        raise e
      end
    end

    def member_by_uid(member_uid)
      @members_by_uid ||=
        list_all_members.each_with_object({}) { |member, acc| acc[member['uid'].to_i] = member }
      @members_by_uid[member_uid.to_i]
    end

    def projects_users
      @projects_users ||= {}
    end

    def projects_tasks
      @projects_tasks ||= {}
    end

    def activate_member(uid)
      workspace_user = list_all_members.find { |m| m['uid'] == uid }
      return workspace_user unless workspace_user['inactive']
      params = { 'inactive' => false }
      toggl_client.update_workspace_user(workspace_user['id'], params)
    end

    def preload_projects_users_with_tasks(team_ids)
      input = Queue.new
      result = Queue.new
      cleanup_team_ids(team_ids, input)
      threads = start_threads(input, result)
      threads.each(&:join)
      until result.empty?
        team_id, project_users, project_tasks = result.pop
        projects_users[team_id.to_i] = project_users
        projects_tasks[team_id.to_i] = project_tasks
      end
    end

    def cleanup_team_ids(team_ids, input)
      team_ids.each { |team_id| input << team_id unless projects_users.key?(team_id.to_i) }
    end

    def start_threads(input, result)
      (1..THREAD_POOL_SIZE).map do
        thread_block = build_preload_projects_users_with_tasks_thread_block(input, result)
        Thread.new(self.class.new(@token, @company_name), &thread_block)
      end
    end

    def build_preload_projects_users_with_tasks_thread_block(input_queue, result_queue)
      lambda do |api|
        until input_queue.empty?
          begin
            team_id = input_queue.pop(true)
            project_users = api.list_projects_users(team_id)
            project_tasks = api.list_projects_tasks(team_id)
            result_queue << [team_id, project_users, project_tasks]
          rescue ThreadError # normal if queue empty
          rescue RuntimeError => e
            if e.message.match(/Too many requests/i)
              input_queue << team_id
              sleep(1)
            else
              raise
            end
          end
        end
      end
    end
  end
end
