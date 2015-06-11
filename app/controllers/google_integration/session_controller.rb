module GoogleIntegration
  class SessionController < ApplicationController
    skip_before_filter :gh_auth_required, only: [:create]
    skip_before_filter :google_auth_required, only: [:create]


    def create
      session[:google_token] = auth_hash[:credentials][:token] if auth_hash[:provider] == 'google_oauth2'
      redirect_to google_show_diff_path
    end
  end
end
