class SessionController < ApplicationController

  skip_before_filter :gh_auth_required, only: [:create, :destroy]
  skip_before_filter :google_auth_required, only: [:create, :destroy]

  expose(:auth_hash){ request.env['omniauth.auth'].with_indifferent_access }

  def create
    session[:token] = auth_hash[:credentials][:token] if auth_hash[:provider] == 'github'
    session[:google_token] = auth_hash[:credentials][:token] if auth_hash[:provider] == 'google_oauth2'
    redirect_to main_index_path
  end

  def destroy
    session[:token] = nil
    session[:google_token] = nil
    redirect_to root_path
  end

end
