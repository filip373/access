class MainController < ApplicationController
  before_action :check_permissions

  expose(:gh_api) { GithubIntegration::Api.new(session[:gh_token], AppConfig.company) }
  expose(:validation_errors) { Storage.validation_errors }

  def index
    UpdateRepo.now!
  end

  def check_permissions
    gh_api.client.patch_request("/orgs/#{gh_api.client.org}")
    rescue Github::Error::NotFound
      render 'main/unauthorized'
  end
end
