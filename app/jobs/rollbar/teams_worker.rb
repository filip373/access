module RollbarWorkers
  class TeamsWorker < Base
    def perform(session_token)
      @session_token = session_token
      set_performing_flag
      rollbar_teams
      calculated_diff
      unset_performing_flag
    end

    def self.applicable_to?(label)
      label == :rollbar
    end

    private

    def calculated_diff
      Rails.cache.fetch('rollbar_calculated_teams') do
        build_projects_for_teams
      end
    end

    def set_performing_flag
      Rails.cache.delete('rollbar_performing_teams')
      Rails.cache.fetch('rollbar_performing_teams') do
        true
      end
    end

    def unset_performing_flag
      Rails.cache.delete('rollbar_performing_teams')
      Rails.cache.fetch('rollbar_performing_teams') do
        false
      end
    end
  end
end
