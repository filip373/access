module GithubWorkers
  class DiffWorker < Base
    def perform(session_token)
      @session_token = session_token
      set_performing_flag
      calculated_diff(expected_teams, gh_teams, gh_api, user_repo)
      calc_diff_errors
      unset_performing_flag
    end

    private

    def calculated_diff(expected_teams, gh_teams, gh_api, user_repo)
      Rails.cache.fetch('github_calculated_diff') do
        @diff ||= GithubIntegration::Actions::Diff.new(expected_teams, gh_teams, gh_api, user_repo)
        @diff.now!
      end
    end

    def calc_diff_errors
      Rails.cache.fetch('github_calculated_errors') do
        @diff_errors = @diff.errors
      end
    end

    def set_performing_flag
      Rails.cache.delete('github_performing_diff')
      Rails.cache.fetch('github_performing_diff') do
        true
      end
    end

    def unset_performing_flag
      Rails.cache.delete('github_performing_diff')
      Rails.cache.fetch('github_performing_diff') do
        false
      end
    end
  end
end
