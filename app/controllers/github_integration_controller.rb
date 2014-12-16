class GithubIntegrationController < ApplicationController
  Dir[File.join(Rails.root, "app/jobs/*.rb")].each {|file| require file.gsub(/\.rb$/,"") }

  expose(:validation_errors) { Storage.validation_errors }
  expose(:gh_api) { GithubIntegration::Api.new(session[:token], AppConfig.company) }
  expose(:expected_teams) { GithubIntegration::Teams.all }
  expose(:gh_diff) { GithubIntegration::Actions::Diff.new(expected_teams, gh_api) }
  expose(:get_gh_log) { GithubIntegration::Actions::Log.new(get_gh_diff) }
  expose(:sync_github_job) { Jobs::SyncGithubJob.new }
  expose(:teams_cleanup) { GithubIntegration::Actions::CleanupTeams.new(expected_teams, gh_api) }
  expose(:missing_teams) { teams_cleanup.stranded_teams }

  def show_diff
    @gh_diff = gh_diff.now!
    @gh_log = get_gh_log.now!
  end

  def sync
    sync_github_job.async.perform(gh_api, get_gh_diff)
    reset_diff
  end

  def cleanup_teams
    teams_cleanup.now!
  end

  private

  def reset_diffs
    @gh_diff = nil
  end

  def get_gh_diff
    @gh_diff ||= gh_diff.now!
  end
end
