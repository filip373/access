module HockeyAppIntegration
  class Api
    attr_accessor :client

    def initialize
      @client = Client.new
    end

    def add_team_to_app(app_id, team_id)
      client.put("/apps/#{app_id}/app_teams/#{team_id}")
    end

    def create_app(options)
      client.post('/apps/new', options)
    end

    def invite_user_to_app(app_id, user_email)
      client.post("/apps/#{app_id}/app_users", email: user_email)
    end

    def list_apps
      client.get('/apps')
    end

    def list_app_teams(app_id)
      client.get("/apps/#{app_id}/app_teams")
    end

    def list_app_users(app_id)
      client.get("/apps/#{app_id}/app_users")
    end

    def list_teams
      client.get('/teams')
    end

    def list_team_members(team_id)
      client.get("/teams/#{team_id}")
    end

    def remove_team_from_app(app_id, team_id)
      client.delete("/apps/#{app_id}/app_teams/#{team_id}")
    end

    def remove_user_from_app(app_id, user_id)
      client.delete("/apps/#{app_id}/app_users/#{user_id}")
    end
  end
end
