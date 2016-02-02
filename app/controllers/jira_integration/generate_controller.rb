module JiraIntegration
  class GenerateController < ApplicationController
    include JiraApi, JiraProtectedEndpoint

    def permissions
      Generate::JiraPermissions.new(
        jira_api,
        permissions_dir,
      ).call

      flash[:notice] = 'Permissions has been created'

      redirect_to root_path
    end

    private

    def permissions_dir
      Rails.root.join('tmp/new_permissions/')
    end
  end
end
