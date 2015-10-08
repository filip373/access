module GithubIntegration
  class MainController < ApplicationController
    include ::GithubApi

    expose(:validation_errors) { DataGuru::Client.new.errors }
    expose(:expected_teams) { Teams.all }
    expose(:gh_teams) { gh_api.list_teams }
    expose(:gh_log) { Actions::Log.new(calculated_diff).now! }
    expose(:teams_cleanup) { Actions::CleanupTeams.new(expected_teams, gh_teams, gh_api) }
    expose(:missing_teams) { teams_cleanup.stranded_teams }
    expose(:diff_errors) { @diff.errors }
    expose(:insecure_users) do
      Actions::ListInsecureUsers.new(
        gh_api.list_org_members_without_2fa(AppConfig.company),
        data_guru.users,
        data_guru.github_teams).call
    end

    after_filter :clean_diff_actor

    def show_diff
      reset_diff
      data_guru.refresh
      calculated_diff
    end

    def sync
      SyncJob.new.perform(gh_api, calculated_diff)
      reset_diff
    end

    def cleanup_teams
      teams_cleanup.now!
    end

    private

    def reset_diff
      Rails.cache.delete 'github_calculated_diff'
    end

    def calculated_diff
      Rails.cache.fetch 'github_calculated_diff' do
        @diff ||= Actions::Diff.new(expected_teams, gh_teams, gh_api)
        @diff.now!
      end
    end

    def clean_diff_actor
      @diff.try(:terminate)
    end
  end
end
