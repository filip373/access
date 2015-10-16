module GithubIntegration
  class MainController < ApplicationController
    include ::GithubApi

    expose(:validation_errors) { data_guru.errors }
    expose(:expected_teams) { Teams.all_from_storage(data_guru.github_teams) }
    expose(:gh_teams) { Teams.all_from_api(gh_api, gh_teams_from_api) }
    expose(:gh_log) { Actions::Log.new(calculated_diff).now! }
    expose(:teams_cleanup) { Actions::CleanupTeams.new(expected_teams, gh_teams, gh_api) }
    expose(:missing_teams) { teams_cleanup.stranded_teams }
    expose(:diff_errors) { [] }
    expose(:insecure_users) do
      Actions::ListInsecureUsers.new(
        gh_api.list_org_members_without_2fa(AppConfig.company),
        data_guru.users,
        data_guru.github_teams).call
    end

    def show_diff
      reset_diff
      data_guru.refresh
      calculated_diff
    end

    def sync
      SyncJob.new.perform(gh_api, calculated_diff, names_and_ids)
      reset_diff
    end

    def cleanup_teams
      teams_cleanup.now!
    end

    private

    def names_and_ids
      Teams.names_and_ids(gh_teams)
    end

    def gh_teams_from_api
      Actions::GetTeamsWithAssoc.new(gh_api).now!
    end

    def reset_diff
      Rails.cache.delete 'github_calculated_diff'
    end

    def calculated_diff
      Rails.cache.fetch 'github_calculated_diff' do
        @diff = BaseDiff.new(expected_teams, gh_teams).diff!
      end
    end
  end
end
