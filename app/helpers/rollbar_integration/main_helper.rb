module RollbarIntegration
  module MainHelper
    def rollbar_team_path(team_id)
      "https://rollbar.com/settings/accounts/#{AppConfig.company}/teams/#{team_id}/"
    end
  end
end
