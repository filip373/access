module GoogleIntegration
  class GenerateController < ApplicationController
    include GoogleApi
    include GithubApi

    def permissions
      Generate::GooglePermissions.new(
        google_api.list_groups_full_info,
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
