module JiraWorkers
  class DiffWorker < Base
    def perform(session_token)
      @session_token = session_token
      set_performing_flag
      calculated_diff
      unset_performing_flag
    end

    def self.applicable_to?(label)
      label == :jira
    end

    private

    def calculated_diff
      Rails.cache.fetch('jira_calculated_diff') do
        JiraIntegration::Actions::Diff.call(api, data_guru)
      end
    end

    def set_performing_flag
      Rails.cache.write('jira_performing_diff', true)
    end

    def unset_performing_flag
      Rails.cache.write('jira_performing_diff', false)
    end
  end
end
