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
      if signet_errors.include? e.message
        google_auth_required
      else
        fail
      end
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
