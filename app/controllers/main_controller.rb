class MainController < ApplicationController
  before_action :check_permissions
  include GithubIntegration

  expose(:gh_api) { GithubIntegration::Api.new(session[:token], AppConfig.company) }

  expose(:expected_teams) { GithubIntegration::Teams.all }

  expose(:validation_errors) { Storage.validation_errors }
  expose(:update_repo) { UpdateRepo.new }

  expose(:gh_diff) { GithubIntegration::Actions::GetDiff.new(expected_teams, gh_api) }

  expose(:sync_github) { GithubIntegration::Actions::SyncTeams.new(gh_api) }

  expose(:get_gh_log) { GithubIntegration::Actions::GetLog.new(get_gh_diff) }

  expose(:teams_cleanup) { GithubIntegration::Actions::CleanupTeams.new(expected_teams, gh_api) }
  expose(:missing_teams) { teams_cleanup.stranded_teams }

  def show_diff
    @gh_diff = gh_diff.now!
    @gh_log = get_gh_log.now!
    render
  end

  def do_sync
    sync_github.now!(get_gh_diff)
    @gh_diff = nil
    render
  end

  def cleanup_teams
    teams_cleanup.now!
    render
  end

  def index
    update_repo.now!
  end

  def check_permissions
    gh_api.client.patch_request("/orgs/#{gh_api.client.org}")
    rescue Github::Error::NotFound
      render 'main/unauthorized'
  end

  private

  def get_gh_diff
    @gh_diff ||= gh_diff.now!
  end
end
