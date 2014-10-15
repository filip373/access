class GithubController < ApplicationController
  expose(:gh_api) { GithubIntegration::Api.new(session[:token], AppConfig.company) }

  expose(:expected_teams) { GithubIntegration::Teams.all }

  expose(:update_repo) { UpdateRepo.new }
  expose(:sync_github) { GithubIntegration::Actions::SyncTeams.new(expected_teams, gh_api) }
  expose(:teams_cleanup) { GithubIntegration::Actions::CleanupTeams.new(expected_teams, gh_api) }
  expose(:missing_teams){ teams_cleanup.stranded_teams }

  def do_sync
    update_repo.now!
    sync_github.now!

    render
  end

  def cleanup_teams
    teams_cleanup.now!

    render
  end


  def index
    update_repo.now!
  end
end
