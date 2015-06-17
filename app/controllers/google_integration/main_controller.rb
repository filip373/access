require 'google/api_client'
require 'google/api_client/client_secrets'

module GoogleIntegration
  class MainController < ApplicationController
    expose(:google_api) { Api.new(session[:credentials]) }
    expose(:expected_groups) { Groups.all }
    expose(:google_log_errors) { log.errors }
    expose(:google_log) { log.log }
    expose(:sync_google_job) { SyncJob.new }
    expose(:groups_cleanup) do
      Actions::CleanupGroups.new(expected_groups, google_api, api_groups)
    end
    expose(:missing_groups) { groups_cleanup.stranded_groups }

    before_filter :google_auth_required, unless: :google_logged_in?
    rescue_from ArgumentError, with: :google_error

    def show_diff
      reset_diff
      UpdateRepo.now!
      Storage.reset_data
    end

    def sync
      sync_google_job.perform(google_api, calculated_diff)
      reset_diff
    end

    def cleanup_groups
      groups_cleanup.now!
    end

    private

    def reset_diff
      Rails.cache.delete 'calculated_diff'
      Rails.cache.delete 'api_groups'
    end

    def calculated_diff
      Rails.cache.fetch 'calculated_diff' do
        @google_diff ||= Actions::Diff.new(expected_groups, google_api)
        diff = @google_diff.now!
        api_groups
        diff
      end
    end

    def api_groups
      Rails.cache.fetch 'api_groups' do
        @google_diff.api_groups
      end
    end

    def google_auth_required
      redirect_to '/auth/google_oauth2'
    end

    def google_error(e)
      if e.message =~ /Missing authorization code./
        google_auth_required
      else
        raise
      end
    end

    def google_logged_in?
      session[:credentials].present?
    end

    def log
      return @log if @log.present?
      @log = Actions::Log.new(calculated_diff)
      @log.generate_log
      @log
    end
  end
end
