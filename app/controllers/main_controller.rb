class MainController < ApplicationController
  before_action :check_permissions
  Dir[File.join(Rails.root, "app/jobs/*.rb")].each {|file| require file.gsub(/\.rb$/,"") }

  expose(:gh_api) { GithubIntegration::Api.new(session[:token], AppConfig.company) }
  expose(:google_api) { GoogleIntegration::Api.new(session[:google_token]) }

  expose(:expected_teams) { GithubIntegration::Teams.all }
  expose(:expected_groups) { GoogleIntegration::Groups.all }

  expose(:validation_errors) { Storage.validation_errors }
  expose(:update_repo) { UpdateRepo.new }

  expose(:gh_diff) { GithubIntegration::Actions::Diff.new(expected_teams, gh_api) }
  # expose(:google_diff) { GoogleIntegration::Actions::Diff.new(expected_groups, google_api) }

  expose(:get_gh_log) { GithubIntegration::Actions::Log.new(get_gh_diff) }
  # expose(:get_google_log) { GoogleIntegration::Actions::Log.new(get_google_diff) }


  expose(:sync_github_job) { Jobs::SyncGithubJob.new }
  # expose(:sync_google_job) { Jobs::SyncGoogleJob.new }

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
    sync_github_job.async.perform(gh_api, get_gh_diff)
    # sync_google_job.async.perform(google_api, get_google_diff)
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
