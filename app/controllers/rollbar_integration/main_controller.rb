module RollbarIntegration
  class MainController < ApplicationController
    expose(:validation_errors) { Storage.validation_errors }
    expose(:expected_teams) { Teams.all }
    expose(:rollbar_teams) { rollbar_api.list_teams }
    expose(:rollbar_log) { Actions::Log.new(calculated_diff).now! }
    expose(:sync_rollbar_job) { SyncJob.new }
    expose(:teams_cleanup) do
      Actions::CleanupTeams.new(expected_teams, rollbar_teams, rollbar_api)
    end
    expose(:missing_teams) { teams_cleanup.stranded_teams }
    expose(:diff_errors) { @diff.errors }
    expose(:rollbar_api) { Api.new }

    after_filter :clean_diff_actor

    def show_diff
      reset_diff
      UpdateRepo.now!
      Storage.reset_data
      calculated_diff
    end

    def sync
      sync_rollbar_job.perform(rollbar_api, calculated_diff)
      reset_diff
    end

    def cleanup_teams
      teams_cleanup.now!
    end

    private

    def reset_diff
      Rails.cache.delete 'rollbar_calculated_diff'
    end

    def calculated_diff
      Rails.cache.fetch 'rollbar_calculated_diff' do
        @diff ||= Actions::Diff.new(expected_teams, rollbar_teams, rollbar_api)
        @diff.now!
      end
    end

    def clean_diff_actor
      @diff.try(:terminate)
    end
  end
end
