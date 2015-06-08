module GithubIntegration
  class MainController < ApplicationController
    expose(:validation_errors) { Storage.validation_errors }
    expose(:gh_api) { Api.new(session[:gh_token], AppConfig.company) }
    expose(:expected_teams) { Teams.all }
    expose(:gh_teams) { gh_api.list_teams }
    expose(:gh_log) { Actions::Log.new(calculated_diff).now! }
    expose(:sync_github_job) { SyncJob.new }
    expose(:teams_cleanup) { Actions::CleanupTeams.new(expected_teams, gh_teams, gh_api) }
    expose(:missing_teams) { teams_cleanup.stranded_teams }
    expose(:update_repo) { UpdateRepo.new }
    expose(:diff_errors) { @diff.errors }

    def show_diff
      reset_diff
      update_repo.now!
      Storage.reset_data
      calculated_diff
    end

    def sync
      sync_github_job.perform(gh_api, calculated_diff)
      reset_diff
    end

    def cleanup_teams
      teams_cleanup.now!
    end

    private

    def reset_diff
      Rails.cache.delete 'calculated_diff'
    end

    def calculated_diff
      Rails.cache.fetch 'calculated_diff' do
        @diff ||= Actions::Diff.new(expected_teams, gh_teams, gh_api)
        @diff.now!
      end
    end
  end
end
