class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :gh_auth_required

  def gh_auth_required
    redirect_to '/auth/github' unless session[:gh_token].present?
  end
end
