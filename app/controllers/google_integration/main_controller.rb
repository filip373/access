module GoogleIntegration
  class MainController < ApplicationController
    expose(:google_api) { GoogleIntegration::Api.new(session[:google_token]) }
    expose(:expected_groups) { GoogleIntegration::Groups.all }
    expose(:google_diff) { GoogleIntegration::Actions::Diff.new(expected_groups, google_api) }
    expose(:get_google_log) { GoogleIntegration::Actions::Log.new(get_google_diff) }
    expose(:sync_google_job) { GoogleIntegration::SyncJob.new }
    expose(:update_repo) { UpdateRepo.new }

    before_filter :google_auth_required, unless: :google_logged_in?
    rescue_from OAuth2::Error, with: :google_error

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
      if e.message =~ /Invalid Credentials/
        google_auth_required
      else
        raise e.message
      end
    end

    def google_logged_in?
      session[:google_token].present?
    end
  end
end
