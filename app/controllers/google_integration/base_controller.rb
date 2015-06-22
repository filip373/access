module GoogleIntegration
  class BaseController < ApplicationController
    rescue_from ArgumentError, with: :google_error

    def google_api
      @google_api ||= Api.new(session[:credentials])
    end

    def google_logged_in?
      session[:credentials].present?
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
  end
end
