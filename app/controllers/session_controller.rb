class SessionController < ApplicationController

  skip_before_filter :gh_auth_required, only: [:destroy, :failure]
  skip_before_filter :google_auth_required, only: [:destroy, :failure]

  def destroy
    session[:gh_token] = nil
    session[:google_token] = nil
    redirect_to root_path
  end

  def failure
  end
end
