module GithubIntegration
  class GenerateController < ApplicationController
    def permissions
      Generate::GithubPermissions.new(
        github_api,
        permissions_dir,
      ).call

      flash[:notice] = 'Permissions has been created'

      redirect_to '/'
    end

    private

    def permissions_dir
      Rails.root.join('tmp/new_permissions/')
    end

    def github_api
      Api.new(session[:gh_token], AppConfig.company)
    end
  end
end
