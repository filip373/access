module JiraIntegration
  class MainController < ApplicationController
    before_action :check_session
    expose(:diff) { JiraFacade.new(data_guru, cached_diff) }

    def calculate_diff
      CalculateDiffStrategist.new(
        controller: self,
        label: :jira,
        data_guru: data_guru,
        session_token: session[:jira_credentials],
      ).call
    end

    def sync
      sync = SyncJob.new.perform(AuditedApi.new(jira_api, current_user), cached_diff)
      reset_diff
      return render(:sync_error, locals: { errors: sync.errors }) if sync.errors.any?
    end

    def refresh_cache
      reset_diff
      redirect_to jira_calculate_diff_path
    end

    private

    def reset_diff
      Rails.cache.delete('jira_calculated_diff')
      Rails.cache.delete('jira_performing_diff')
    end

    def cached_diff
      Rails.cache.fetch('jira_calculated_diff')
    end

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
