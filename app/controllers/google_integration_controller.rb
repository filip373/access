class GithubIntegrationController < ApplicationController
  Dir[File.join(Rails.root, "app/jobs/*.rb")].each {|file| require file.gsub(/\.rb$/,"") }

  expose(:google_api) { GoogleIntegration::Api.new(session[:google_token]) }
  expose(:expected_groups) { GoogleIntegration::Groups.all }
  expose(:google_diff) { GoogleIntegration::Actions::Diff.new(expected_groups, google_api) }
  expose(:get_google_log) { GoogleIntegration::Actions::Log.new(get_google_diff) }
  expose(:sync_google_job) { Jobs::SyncGoogleJob.new }

  def show_diff
    @google_diff = google_diff.now!
    @google_log = get_google_log.now!
  end

  def sync
    sync_google_job.async.perform(google_api, get_google_diff)
    reset_diff
  end

  private

  def reset_diff
    @gh_diff = nil
  end

  def get_google_diff
    @google_diff ||= google_diff.now!
  end
end
