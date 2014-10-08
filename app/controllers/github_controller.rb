class GithubController < ApplicationController
  expose(:gh_api) { GithubIntegration::Api.new(session[:token], AppConfig.company) }

  expose(:expected_teams) { GithubIntegration::Teams.all }

  expose(:update_repo) { UpdateRepo.new }
  expose(:sync_github) { GithubIntegration::Actions::SyncTeams.new(expected_teams, gh_api) }

  def do_sync
    update_repo.now!
    sync_github.now!

    render
  end

  def index
  end
end
