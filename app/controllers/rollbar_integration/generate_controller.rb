module RollbarIntegration
  class GenerateController < ApplicationController
    expose(:user_repo) { UserRepository.new(data_guru.users) }
    expose(:rollbar_api) { Api.new }

    def permissions
      Generate::RollbarPermissions.new(
        rollbar_api,
        permissions_dir,
        user_repo,
      ).call

      flash[:notice] = 'Rollbar permissions has been created'

      redirect_to root_path
    end

    private

    def permissions_dir
      Rails.root.join('tmp/new_permissions/')
    end
  end
end
