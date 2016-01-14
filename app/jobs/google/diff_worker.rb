module GoogleWorkers
  class DiffWorker < Base
    def perform(session_token)
      @session_token = session_token
      set_performing_flag
      calculate_diff
      unset_performing_flag
    end

    def self.applicable_to?(label)
      label == :google
    end

    private

    def set_performing_flag
      Rails.cache.write('gooogle_performing_diff', true)
    end

    def calculate_diff
      Rails.cache.fetch('google_calculated_diff') do
        @diff ||= GoogleIntegration::Actions::Diff.new(expected_groups, google_api, user_repo)
        @diff.now!
      end
    end

    def unset_performing_flag
      Rails.cache.write('google_performing_diff', false)
    end
  end
end
