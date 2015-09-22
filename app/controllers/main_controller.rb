class MainController < ApplicationController
  include ::GithubApi
  before_action :check_permissions

  expose(:validation_errors) { Storage.validation_errors }

  def check_permissions
    gh_api.client.patch_request("/orgs/#{gh_api.client.org}")
    rescue Github::Error::NotFound
      render 'main/unauthorized'
  end
end
