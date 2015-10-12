module TogglIntegration
  class GenerateController < ApplicationController
    def permissions
      Generate::TogglPermissions.new(
        toggl_teams,
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
      Api.new(AppConfig.toggl_token, AppConfig.company)
    end

    def toggl_teams
      TeamRepository.build_from_toggl_api(toggl_api, UserRepository.new).all
    end
  end
end
