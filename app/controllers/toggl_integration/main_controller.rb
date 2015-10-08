module TogglIntegration
  class MainController < ApplicationController
    CACHE_KEY_NAME = 'toggl_calculated_diff'.freeze

    expose(:validation_errors) { DataGuru::Client.new.errors }
    expose(:diff_errors) { @diff.errors }
    expose(:toggl_log) { Actions::Log.new(calculated_diff).call }
    expose(:missing_teams) { calculated_diff[:missing_teams] }
    expose(:workspace_id) { Api.new.workspace['id'] }

    def show_diff
      reset_diff
      UpdateRepo.now!
      calculated_diff
    end

    def sync
    end

    def cleanup_teams
    end

    private

    def reset_diff
      Rails.cache.delete CACHE_KEY_NAME
    end

    def calculated_diff
      Rails.cache.fetch CACHE_KEY_NAME do
        @diff ||= Actions::Diff.new(local_teams, Api.new)
        @diff.call
      end
    end

    def local_teams
      Teams.all
    end
  end
end
