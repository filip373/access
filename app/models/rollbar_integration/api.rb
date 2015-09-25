module RollbarIntegration
  class Api
    attr_accessor :client

    def initialize(token: AppConfig.rollbar.token)
      self.client = Client.new(token)
    end

    def list_teams
      client.get('/api/1/teams')
        .reject { |e| e.name == 'Owners' }
    end

    def list_team_members(team_id)
      client.get_all_pages("/api/1/team/#{team_id}/users")
        .map { |member| get_member(member['user_id']) }
    end

    def list_account_projects
      client.get('/api/1/projects')
    end

    def list_team_projects(team_id)
      client.get_all_pages("/api/1/team/#{team_id}/projects")
        .map { |project| get_project(project['project_id']) }
    end

    def list_team_invities(team_id)
      client.get("/api/1/team/#{team_id}/invites")
    end

    def create_team(name, access_level = 'standard')
      options = { body: { name: name, access_level: access_level } }
      team = client.post('/api/1/teams', options)
      yield team
    end

    def create_project(name)
      options = { body: { name: name } }
      client.post('/api/1/projects', options)
    end

    def add_project_to_team(project_id, team_id)
      client.put("/api/1/team/#{team_id}/project/#{project_id}")
    end

    def invite_member_to_team(email, team_id)
      options = { body: { email: email } }
      client.post("/api/1/team/#{team_id}/invites", options)
    end

    def remove_member_from_team(user_id, team_id)
      client.delete("/api/1/team/#{team_id}/user/#{user_id}")
    end

    def remove_team(team_id)
      client.delete("/api/1/team/#{team_id}")
    end

    def remove_project_from_team(project_id, team_id)
      client.delete("/api/1/team/#{team_id}/project/#{project_id}")
    end

    def cancel_invitation(invitation_id)
      client.delete("/api/1/invite/#{invitation_id}")
    end

    private

    def get_member(user_id)
      Rails.cache.fetch("get_member-#{user_id}") do
        client.get("/api/1/user/#{user_id}")
      end
    end

    def get_project(project_id)
      Rails.cache.fetch("get_project-#{project_id}") do
        client.get("/api/1/project/#{project_id}")
      end
    end
  end
end
