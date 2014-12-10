class MainController < ApplicationController
  before_action :check_permissions
  require Rails.root.join("app/models/actions/get_log")
  require Rails.root.join("app/models/actions/get_diff")
  require Rails.root.join("app/models/actions/sync")
  require Rails.root.join("app/models/github_integration/actions/get_log")
  require Rails.root.join("app/models/github_integration/actions/get_diff")
  require Rails.root.join("app/models/github_integration/actions/sync_teams")
  require Rails.root.join("app/models/google_integration/actions/get_log")
  require Rails.root.join("app/models/google_integration/actions/get_diff")

  expose(:gh_api) { GithubIntegration::Api.new(session[:token], AppConfig.company) }
  expose(:google_api) { GoogleIntegration::Api.new(session[:google_token]) }

  expose(:expected_teams) { GithubIntegration::Teams.all }
  expose(:expected_groups) { GoogleIntegration::Groups.all }

  expose(:validation_errors) { Storage.validation_errors }
  expose(:update_repo) { UpdateRepo.new }

  expose(:gh_diff) { Diff::Github.new(expected_teams, gh_api) }
  # expose(:google_diff) { Diff::Google.new(expected_groups, google_api) }

  expose(:get_gh_log) { Log::Github.new(get_gh_diff) }
  # expose(:get_google_log) { Log::Google.new(get_google_diff) }

  expose(:sync_github) { Sync::Github.new(gh_api) }
  # expose(:sync_google) { GoogleIntegration::Actions::SyncGroups.new(google_api) }

  expose(:teams_cleanup) { GithubIntegration::Actions::CleanupTeams.new(expected_teams, gh_api) }
  expose(:missing_teams) { teams_cleanup.stranded_teams }

  def show_diff
    @gh_diff = gh_diff.now!
    @gh_log = get_gh_log.now!
    # @google_diff = google_diff.now!
    # @google_log = get_google_log.now! || []
    @google_log = []
  end

  def do_sync
    sync_github.now!(get_gh_diff)
    # sync_google.now!(get_google_diff)
    reset_diffs
  end

  def cleanup_teams
    teams_cleanup.now!
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

  def reset_diffs
    @gh_diff = nil
    @google_diff = nil
  end

  def get_gh_diff
    @gh_diff ||= gh_diff.now!
  end

  def get_google_diff
    # @google_diff ||= google_diff.now!
  end
end
