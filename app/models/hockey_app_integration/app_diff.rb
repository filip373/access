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
      diff_add_teams
      diff_remove_teams
    end

    def diff_users
      diff_users_with_role(:add_users, :testers)
      diff_users_with_role(:add_users, :members)
      diff_users_with_role(:add_users, :developers)
      diff_users_with_role(:remove_users, :developers)
      diff_users_with_role(:remove_users, :members)
      diff_users_with_role(:remove_users, :testers)
    end

    def diff_add_teams
      teams_to_add = expected_app.teams - api_app.teams
      diff_hash[:add_teams][expected_app] = teams_to_add if teams_to_add.any?
    end

    def diff_remove_teams
      teams_to_remove = api_app.teams - expected_app.teams
      diff_hash[:remove_teams][expected_app] = teams_to_remove if teams_to_remove.any?
    end

    def diff_users_with_role(label, role)
      users = arrayed_users(label, role)
      diff_hash[label][expected_app] ||= {}
      diff_hash[label][expected_app][role] = users if users.any?
    end

    def arrayed_users(label, role)
      if label == :add_users
        return expected_app.public_send(role) - api_app.public_send(role)
      else
        return api_app.public_send(role) - expected_app.public_send(role)
      end
    end
  end
end
