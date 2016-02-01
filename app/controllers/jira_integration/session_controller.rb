module JiraIntegration
  class SessionController < ApplicationController
    skip_before_filter :gh_auth_required, only: [:create]
    skip_before_filter :google_auth_required, only: [:create]

    expose(:auth_hash) { request.env['omniauth.auth'].with_indifferent_access }

    def create
      session[:jira_credentials] = auth_hash[:credentials] if auth_hash[:provider] == 'jira'
      redirect_to jira_show_diff_path
    end
  end
end
