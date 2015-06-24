module GoogleIntegration
  class BaseController < ApplicationController
    rescue_from ArgumentError, with: :google_error
    rescue_from GoogleIntegration::ApiError, with: :suggest_relogin

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
      if signet_errors.include? e.message
        google_auth_required
      else
        fail
      end
    end

    def suggest_relogin(e)
      flash[:api_error] = "We've encountered a problem with API: `#{e}`."
      redirect_to root_url
    end

    def signet_errors
      [
        'Missing required redirect URI.',
        'Missing token endpoint URI.',
        'Missing authorization code.',
        'Missing access token.',
      ]
    end
  end
end
