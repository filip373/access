class GenerateController < ApplicationController
  include GoogleApi
  include GithubApi

  def users
    Generate::Users.new(
      google_api,
      gh_api,
      permissions_dir,
    ).call

    flash[:notice] = 'Users have been created'

    redirect_to '/'
  end

  private

  def permissions_dir
    Rails.root.join('tmp/new_permissions/')
  end
end
