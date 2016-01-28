module JiraIntegration
  class MainController < ApplicationController
    before_action :check_session
    expose(:diff) { Actions::Diff.call(jira_api, data_guru) }

    private

    def jira_client
      return @client if @client
      @client ||= JIRA::Client.new(private_key_file: AppConfig.jira.private_key_path,
                                   consumer_key: AppConfig.jira.consumer_key,
                                   site: AppConfig.jira.site,
                                   context_path: '')
      @client.set_access_token(session[:jira_credentials][:token],
                               session[:jira_credentials][:secret])
      @client
    end

    def jira_api
      @jira_api ||= Api.new(jira_client)
    end

    def check_session
      redirect_to '/auth/jira' if jira_credentials.nil?
    end
  end
end
