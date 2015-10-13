module TogglIntegration
  class Api
    ProjectUser = Struct.new(:id, :uid)

    attr_reader :toggl_client, :company_name

    def initialize(token, company_name)
      @toggl_client = TogglV8::API.new(token)
      @company_name = company_name
    end

    def list_teams
      toggl_client.projects(workspace['id'])
    end

    def list_all_members
      toggl_client.workspace_users(workspace['id'])
    end

    def list_team_members(team_id)
      list_projects_users(team_id).map do |project_user|
        member_by_uid(project_user.uid)
      end
    end

    def delete_team(team_id)
      toggl_client.delete_project(team_id)
    end

    def add_member_to_team(member, team)
      user = list_projects_users(team.id).find { |user| user['uid'] == member.toggl_id }
      unless user
        params = { 'uid' => member.toggl_id, 'pid' => team.id }
        toggl_client.create_project_user(params)
      end
    end

    def remove_member_from_team(member, team)
      project_users = list_projects_users(team.id)
      project_user_id = project_users.find { |pu| pu.uid == member.toggl_id }.id
      toggl_client.delete_project_user(project_user_id)
    end

    def create_team(team)
      params = { 'name' => team.name, 'wid' => workspace['id'] }
      toggl_client.create_project(params)
    end

    def workspace
      @workspace ||=
      toggl_client.workspaces.find { |workspace| workspace['name'] == company_name }
    end

    private

    def member_by_uid(member_uid)
      @all_members ||=
      list_all_members.each_with_object({}) { |member, acc| acc[member['uid'].to_i] = member }
      @all_members[member_uid.to_i]
    end

    def list_projects_users(team_id)
      team_id = team_id.to_i
      @projects_users ||= {}
      if @projects_users.key?(team_id)
        @projects_users[team_id]
      else
        projects_users = toggl_client.get_project_users(team_id)
        @projects_users[team_id] = projects_users.each_with_object([]) do |pu, users|
          users << ProjectUser.new(pu['id'], pu['uid'])
        end
      end
    end
  end
end
