module TogglIntegration
  class GenerateController < ApplicationController
    def permissions
      Generate::TogglPermissions.new(
        toggl_api,
        permissions_dir,
      ).call

      flash[:notice] = 'Toggl permissions has been created'

      redirect_to root_path
    end

    private

    def permissions_dir
      Rails.root.join('tmp/new_permissions/')
    end

    def toggl_api
      Api.new
    end
  end
end
