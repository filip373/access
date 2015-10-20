module TogglIntegration
  class MainController < ApplicationController
    CACHE_KEY_NAME = 'toggl_calculated_diff'.freeze

    expose(:validation_errors) { data_guru.errors }
    expose(:diff_errors) { @diff.errors.uniq }
    expose(:toggl_log) { Actions::Log.new(calculated_diff).call }
    expose(:missing_teams) { calculated_diff[:missing_teams] }
    expose(:toggl_api) { Api.new(AppConfig.toggl_token, AppConfig.company) }
    expose(:workspace_id) { toggl_api.workspace['id'] }

    def show_diff
      reset_diff
      data_guru.refresh
      calculated_diff
    end

    def sync
      Actions::Sync.new(calculated_diff, toggl_api).call
    end

    def cleanup_teams
      Actions::CleanupTeams.new(missing_teams, toggl_api).call
    end

    private

    def reset_diff
      Rails.cache.delete CACHE_KEY_NAME
    end

    def calculated_diff
      Rails.cache.fetch CACHE_KEY_NAME do
        @diff ||= Actions::Diff.new(expected_teams,
                                    current_teams,
                                    current_members_repository)
        @diff.call
      end
    end

    def current_teams
      TeamRepository.build_from_toggl_api(toggl_api, UserRepository.new).all
    end

    def expected_teams
      TeamRepository.build_from_data_guru(
        data_guru,
        UserRepository.new,
        current_members_repository).all
    end

    def current_members_repository
      MemberRepository.build_from_toggl_api(toggl_api)
    end
  end
end
