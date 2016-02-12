module JiraProtectedEndpoint
  extend ActiveSupport::Concern

  included do
    before_action :check_session
  end

  def check_session
    return true if jira_credentials.present?
    session[:requested_route] = request.path
    redirect_to '/auth/jira'
  end

  def jira_credentials
    session[:jira_credentials]
  end
end
