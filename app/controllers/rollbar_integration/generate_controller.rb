module RollbarIntegration
  class GenerateController < ApplicationController
    def permissions
      Generate::RollbarPermissions.new(
        rollbar_api,
        permissions_dir,
      ).call

      flash[:notice] = 'Rollbar permissions has been created'

      redirect_to root_path
    end

    private

    def permissions_dir
      Rails.root.join('tmp/new_permissions/')
    end

    def rollbar_api
      Api.new
    end
  end
end
