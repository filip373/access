module GithubIntegration
  class MainController < ApplicationController
    include ::GithubApi

    expose(:validation_errors) { data_guru.errors }
    expose(:expected_teams) { GithubIntegration::Team.all(data_guru.github_teams) }
    expose(:gh_teams) { gh_api.list_teams }
    expose(:gh_log) { Actions::Log.new(calculated_diff).now! }
    expose(:list_teamless_users?) { AppConfig.features.list_teamless_github_users }
    expose(:teams_cleanup) do
      Actions::CleanupTeams.new(expected_teams, gh_teams, AuditedApi.new(gh_api, current_user))
    end
    expose(:members_cleanup) do
      Actions::CleanupMembers.new(
        teamless_users.fetch(:missing_from_dg),
        AuditedApi.new(gh_api, current_user),
        AppConfig.company)
    end
    expose(:missing_teams) { teams_cleanup.stranded_teams }
    expose(:diff_errors) { @diff_errors }
    expose(:user_repo) { UserRepository.new(data_guru.members.all) }
    expose(:insecure_users) do
      Actions::ListUsers.new(
        gh_api.list_org_members_without_2fa(AppConfig.company),
        data_guru.members,
        data_guru.github_teams,
        :unsecure).call
    end
    expose(:teamless_users) do
      Actions::ListUsers.new(
        gh_api.list_teamless_members,
        data_guru.members,
        data_guru.github_teams,
        :teamless).call
    end

    after_filter :clean_diff_actor

    def calculate_diff
      CalculateDiffStrategist.new(
        controller: self,
        label: :github,
        data_guru: data_guru,
        session_token: session[:gh_token],
      ).call
    end

    def show_diff
    end

    def cleanup_complete
    end

    def sync
      SyncJob.new.perform(AuditedApi.new(gh_api, current_user), calculated_diff)
      reset_diff
    end

    def cleanup_teams
      teams_cleanup.now!
      redirect_to github_cleanup_complete_path
    end

    def cleanup_members
      members_cleanup.now!
      redirect_to github_cleanup_complete_path
    end

    def refresh_cache
      reset_diff
      redirect_to github_calculate_diff_path
    end

    private

    def reset_diff
      Rails.cache.delete('github_calculated_diff')
      Rails.cache.delete('github_calculated_errors')
      Rails.cache.delete('github_performing_diff')
    end

    def calculated_diff
      Rails.cache.fetch('github_calculated_diff')
    end

    def calc_diff_errors
      Rails.cache.fetch('github_calculated_errors')
    end

    def clean_diff_actor
      @diff.try(:terminate)
    end
  end
end
