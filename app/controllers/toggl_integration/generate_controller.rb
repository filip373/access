module TogglIntegration
  class GenerateController < ApplicationController
    expose(:user_repo) { UserRepository.new(data_guru.members) }

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
      TeamRepository.build_from_toggl_api(toggl_api, user_repo).all
    end
  end
end
