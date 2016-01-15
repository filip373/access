module RollbarWorkers
  class TeamsWorker < Base
    def perform(session_token)
      @session_token = session_token
      set_performing_flag
      fetch_basic_teams
      calculated_diff
      unset_performing_flag
    end

    def self.applicable_to?(label)
      label == :rollbar
    end

    private

    def calculated_diff
      Rails.cache.fetch('rollbar_calculated_teams') do
        api_teams
      end
    end

    def set_performing_flag
      Rails.cache.write('rollbar_performing_teams', true)
    end

    def unset_performing_flag
      Rails.cache.write('rollbar_performing_teams', false)
    end
  end
end
