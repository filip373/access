class GithubController < ApplicationController
  expose(:gh_api) { GithubIntegration::Api.new(session[:token], AppConfig.company) }

  expose(:expected_teams) { GithubIntegration::Teams.all[0..4] }

  expose(:sync_permissions_repo) { UpdateRepo.new }
  expose(:sync) { GithubIntegration::Actions::SyncTeams.new(expected_teams, gh_api) }

  def do_sync
    sync_permissions_repo.now!
    sync.now!

    render
  end

  def index
  end
end
