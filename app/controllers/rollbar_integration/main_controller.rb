module RollbarIntegration
  class MainController < ApplicationController
    expose(:validation_errors) { data_guru.errors }
    expose(:dataguru_teams) { RollbarIntegration::Team.all_from_dataguru(data_guru.rollbar_teams) }
    expose(:rollbar_teams) { RollbarIntegration::Team.all_from_api(rollbar_api) }

    expose(:pending_invitations) do
      Actions::ListPendingInvitations.new(rollbar_api).now!
    end
    expose(:rollbar_log) { Actions::Log.new(calculated_diff).now! }
    expose(:teams_cleanup) do
      Actions::CleanupTeams.new(dataguru_teams, rollbar_teams, rollbar_api)
    end
    expose(:missing_teams) { teams_cleanup.stranded_teams }
    expose(:diff_errors) { @diff.errors.uniq.sort { |a, b| a.to_s <=> b.to_s } }
    expose(:rollbar_api) { Api.new }
    expose(:user_repo) { UserRepository.new(data_guru.users) }

    after_filter :clean_diff_actor

    def show_diff
      reset_diff
      data_guru.refresh
      calculated_diff
    end

    def sync
      SyncJob.new.perform(rollbar_api, calculated_diff)
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
        @diff ||= Actions::Diff.new(dataguru_teams, rollbar_teams, user_repo)
        @diff.now!
      end
    end

    def clean_diff_actor
      @diff.try(:terminate)
    end
  end
end
