module TogglIntegration
  class MainController < ApplicationController
    expose(:validation_errors) { data_guru.errors }
    expose(:diff_errors) { diff_errors }
    expose(:toggl_log) { Actions::Log.new(calculated_diff).call }
    expose(:missing_teams) { calculated_diff[:missing_teams] }
    expose(:toggl_api) { Api.new(AppConfig.toggl_token, AppConfig.company) }
    expose(:workspace_id) { toggl_api.workspace['id'] }
    expose(:user_repo) { UserRepository.new(data_guru.members.all) }

    def calculate_diff
      CalculateDiffStrategist.new(self, :toggl, data_guru, session[:gh_token]).call
    end

    def show_diff
    end

    def refresh_cache
      reset_diff
      redirect_to toggl_calculate_diff_path
    end

    def sync
      Actions::SyncJob.new(calculated_diff, AuditedApi.new(toggl_api, current_user)).call
    end

    def cleanup_teams
      Actions::CleanupTeams.new(missing_teams, AuditedApi.new(toggl_api, current_user)).call
    end

    private

    def reset_diff
      Rails.cache.delete('toggl_calculated_diff')
      Rails.cache.delete('toggl_performing_diff')
      Rails.cache.delete('toggl_calculated_errors')
    end

    def diff_errors
      Rails.cache.fetch('toggl_calculated_errors')
    end

    def calculated_diff
      Rails.cache.fetch('toggl_calculated_diff')
    end

    def current_teams
      TeamRepository.build_from_toggl_api(toggl_api, user_repo).all
    end

    def expected_teams
      TeamRepository.build_from_data_guru(
        data_guru,
        user_repo,
        current_members_repository).all
    end

    def current_members_repository
      MemberRepository.build_from_toggl_api(toggl_api)
    end

    def current_tasks_repository
      TaskRepository.build_from_toggl_api(toggl_api)
    end
  end
end
