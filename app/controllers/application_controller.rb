class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include ::DataGuruClient
  before_filter :gh_auth_required
  helper_method :current_user

  def gh_auth_required
    redirect_to '/auth/github' unless session[:gh_token].present?
  end

  def current_user
    @current_user ||= OpenStruct.new(session[:current_user])
  end

  def jira_credentials
    return if session[:jira_credentials].nil?
    return if Time.zone.at(session[:jira_credentials][:expires_at]) < Time.zone.now
    @jira_credentials ||= OpenStruct.new(session[:jira_credentials])
  end
end
