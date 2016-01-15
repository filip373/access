module GithubWorkers
  class DiffWorker < Base
    def perform(session_token)
      @session_token = session_token
      set_performing_flag
      calculated_diff
      calc_diff_errors
      unset_performing_flag
    end

    def self.applicable_to?(label)
      label == :github
    end

    private

    def calculated_diff
      Rails.cache.fetch('github_calculated_diff') do
        @diff ||= GithubIntegration::Actions::Diff.new(expected_teams, api_teams, api, user_repo)
        @diff.now!
      end
    end

    def calc_diff_errors
      Rails.cache.fetch('github_calculated_errors') do
        @diff_errors = @diff.errors
      end
    end

    def set_performing_flag
      Rails.cache.write('github_performing_diff', true)
    end

    def unset_performing_flag
      Rails.cache.write('github_performing_diff', false)
    end
  end
end
