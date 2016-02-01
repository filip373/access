module JiraWorkers
  class Base < BaseWorker
    private

    def api
      @api ||= JiraIntegration::Api.new(jira_client)
    end

    def jira_client
      return @client if @client
      @client ||= JIRA::Client.new(private_key_file: AppConfig.jira.private_key_path,
                                   consumer_key: AppConfig.jira.consumer_key,
                                   site: AppConfig.jira.site,
                                   context_path: '')
      @client.set_access_token(@session_token[:token],
                               @session_token[:secret])
      @client
    end
  end
end
