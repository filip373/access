module JiraApi
  extend ActiveSupport::Concern

  def jira_client
    return @client if @client
    @client ||= JIRA::Client.new(private_key_file: AppConfig.jira.private_key_path,
                                 consumer_key: AppConfig.jira.consumer_key,
                                 site: AppConfig.jira.site,
                                 context_path: '')
    @client.set_access_token(jira_credentials[:token],
                             jira_credentials[:secret])
    @client
  end

  def jira_api
    @jira_api ||= JiraIntegration::Api.new(jira_client)
  end
end
