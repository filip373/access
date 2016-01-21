module HockeyAppIntegration
  class AppDiff
    attr_reader :expected_app, :api_app, :diff_hash
    def initialize(expected_app, api_app, diff_hash)
      @expected_app = expected_app
      @api_app = api_app
      @diff_hash = diff_hash
    end

    def diff!
      diff_teams
      diff_users
    end

    private

    def diff_teams
      teams_to_add = expected_app.teams - api_app.teams
      teams_to_remove = api_app.teams - expected_app.teams
      diff_hash[:add_teams][expected_app] = teams_to_add if teams_to_add.any?
      diff_hash[:remove_teams][expected_app] = teams_to_remove if teams_to_remove.any?
    end

    def diff_users
      users_to_add = expected_app.users - api_app.users
      users_to_remove = api_app.users - expected_app.users
      diff_hash[:add_users][expected_app] = users_to_add if users_to_add.any?
      diff_hash[:remove_users][expected_app] = users_to_remove if users_to_remove.any?
    end
  end
end
