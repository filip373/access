module TogglIntegration
  class Api
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
      project_users = toggl_client.get_project_users(team_id)
      project_users.map { |project_user| member_by_uid(project_user['uid']) }
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
  end
end
