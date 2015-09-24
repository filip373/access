module RollbarIntegration
  class Api
    attr_accessor :client

    def initialize(read_token: AppConfig.rollbar.read_token,
                   write_token: AppConfig.rollbar.write_token)
      self.client = Client.new(read_token: read_token, write_token: write_token)
    end

    def list_teams
      client.get('/api/1/teams').map { |team| Hashie::Mash.new(team) }
    end

    def list_team_members(team_id)
      client.get_all_pages("/api/1/team/#{team_id}/users")
        .map { |member| get_member(member['user_id']) }
    end

    def list_team_projects(team_id)
      client.get_all_pages("/api/1/team/#{team_id}/projects")
        .map { |project| get_project(project['project_id']) }
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

    def remove_team(team_id)
      client.delete("/api/1/team/#{team_id}")
    end

    private

    def get_member(user_id)
      Hashie::Mash.new(client.get("/api/1/user/#{user_id}"))
    end

    def get_project(project_id)
      Hashie::Mash.new(client.get("/api/1/project/#{project_id}"))
    end
  end
end
