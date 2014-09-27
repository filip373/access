class GithubController < ApplicationController
  expose(:gh_api) {  GhApi.new(session[:token], AppConfig.company) }

  expose(:expected_teams) { ExpectedTeams.new.all }
  expose(:expected_users) { ExpectedUsers.new.all }

  expose(:sync_permissions) { Actions::SyncPermissions.new }
  expose(:sync) { Actions::SyncTeams.new(expected_teams, expected_users, gh_api) }

  def do_sync
    sync_permissions.now!
    sync.now!

  	render
	end

  def index
  end
end
