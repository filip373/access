module RollbarIntegration
  class MainController < ApplicationController
    expose(:validation_errors) { data_guru.errors }
    expose(:user_repo) { UserRepository.new(data_guru.users.all) }
    expose(:dataguru_teams) { RollbarIntegration::Team.all_from_dataguru(data_guru.rollbar_teams) }

    expose(:pending_invitations) do
      Actions::ListPendingInvitations.new(rollbar_api).now!
    end
    expose(:rollbar_log) { Actions::Log.new(calculated_diff).now! }
    expose(:teams_cleanup) do
      Actions::CleanupTeams.new(dataguru_teams,
                                rollbar_teams,
                                AuditedApi.new(rollbar_api, current_user))
    end
    expose(:missing_teams) { teams_cleanup.stranded_teams }
    expose(:diff_errors) { @diff.errors.uniq.sort { |a, b| a.to_s <=> b.to_s } }
    expose(:rollbar_api) { Api.new }

    after_filter :clean_diff_actor

    def pre_heat_cache
      reset_diff
      data_guru.refresh
      rollbar_teams
      redirect_to action: :show_diff
    end

    def show_diff
      build_projects_for_teams
      calculated_diff
    end

    def sync
      SyncJob.new.perform(AuditedApi.new(rollbar_api, current_user), calculated_diff)
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

    def rollbar_teams
      @rollbar_teams ||= RollbarIntegration::Team.all_from_api(rollbar_api, user_repo)
    end

    def build_projects_for_teams
      @rollbar_teams = RollbarIntegration::Team.add_projects(rollbar_teams, rollbar_api)
    end
  end
end
