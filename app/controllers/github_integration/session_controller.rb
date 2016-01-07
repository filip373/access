module GithubIntegration
  class SessionController < ApplicationController
    skip_before_filter :gh_auth_required, only: [:create]
    skip_before_filter :google_auth_required, only: [:create]

    expose(:auth_hash) { request.env['omniauth.auth'].with_indifferent_access }

    def create
      session[:current_user] = auth_hash[:info]
      session[:gh_token] = auth_hash[:credentials][:token] if auth_hash[:provider] == 'github'
      redirect_to root_path
    end
  end
end
