module TogglWorkers
  class DiffWorker < Base
    def perform(session_token)
      @session_token = session_token
      set_performing_flag
      calculate_diff
      calculate_errors
      unset_performing_flag
    end

    def self.applicable_to?(label)
      label == :toggl
    end

    private

    def set_performing_flag
      Rails.cache.write('toggl_performing_diff', true)
    end

    def calculate_diff
      Rails.cache.fetch('toggl_calculated_diff') do
        @diff ||= TogglIntegration::Actions::Diff.new(
          expected_teams,
          api_teams,
          user_repo,
          current_members_repository,
          current_tasks_repository)
        @diff.call
      end
    end

    def calculate_errors
      Rails.cache.fetch('toggl_calculated_errors') do
        @diff_errors ||= @diff.errors.uniq
      end
    end

    def unset_performing_flag
      Rails.cache.write('toggl_performing_diff', false)
    end
  end
end
