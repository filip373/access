class SessionController < ApplicationController

  skip_before_filter :such_auth_required, only: [:create]

  expose(:auth_hash){ request.env['omniauth.auth'].with_indifferent_access }

  def create
    session[:token] = auth_hash[:credentials][:token]
    redirect_to github_index_path
  end

end
