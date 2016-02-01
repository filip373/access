module JiraWorkers
  class Base < BaseWorker
    include JiraApi

    def self.diff_key
      'jira_performing_diff'
    end

    private

    def api
      jira_api
    end

    def jira_credentials
      @session_token
    end
  end
end
