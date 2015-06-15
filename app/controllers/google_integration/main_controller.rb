require 'google/api_client'
require 'google/api_client/client_secrets'

module GoogleIntegration
  class MainController < ApplicationController
    expose(:google_api) { Api.new(session[:credentials]) }
    expose(:expected_groups) { Groups.all }
    expose(:google_diff) { Actions::Diff.new(expected_groups, google_api) }
    expose(:get_google_log) { Actions::Log.new(get_google_diff) }
    expose(:sync_google_job) { SyncJob.new }
    expose(:update_repo) { UpdateRepo.new }
    expose(:groups_cleanup) { Actions::CleanupGroups.new(expected_groups, google_api, google_diff.api_groups) }
    expose(:missing_groups) { groups_cleanup.stranded_groups }

    before_filter :google_auth_required, unless: :google_logged_in?
    rescue_from OAuth2::Error, with: :google_error
    rescue_from ArgumentError, with: :google_error

    def show_diff
      update_repo.now!
      Storage.reset_data
      @google_diff = google_diff.now!
      @google_log = get_google_log.now!
    end

    def sync
      sync_google_job.perform(google_api, get_google_diff)
      reset_diff
    end

    def cleanup_groups
      groups_cleanup.now!
    end

    private

    def reset_diff
      @google_diff = nil
    end

    def get_google_diff
      @google_diff ||= google_diff.now!
    end

    def google_auth_required
      redirect_to '/auth/google_oauth2'
    end

    def google_error(e)
      if e.message =~ /Invalid Credentials/ || e.message =~ /Missing authorization code./
        google_auth_required
      else
        raise e.message
      end
    end

    def google_logged_in?
      session[:credentials].present?
    end
  end
end
