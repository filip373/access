class MainController < ApplicationController
  include ::GithubApi
  before_action :check_permissions

  expose(:validation_errors) { data_guru.errors }
  expose(:todays_logs) { TodaysLogs.call }

  def check_permissions
    data_guru.refresh
    gh_api.client.patch_request("/orgs/#{gh_api.client.org}")
  rescue Github::Error::NotFound
    render 'main/unauthorized'
  end
end
