module RollbarIntegration
  class MainController < ApplicationController
    expose(:validation_errors) { data_guru.errors }
    expose(:user_repo) { UserRepository.new(data_guru.members.all) }
    expose(:dataguru_teams) { RollbarIntegration::Team.all_from_dataguru(data_guru.rollbar_teams) }

    expose(:pending_invitations) { cached_invitations }
    expose(:rollbar_log) { Actions::Log.new(calculated_diff).now! }
    expose(:teams_cleanup) do
      Actions::CleanupTeams.new(dataguru_teams,
                                rollbar_teams,
                                AuditedApi.new(rollbar_api, current_user))
    end
    expose(:missing_teams) { teams_cleanup.stranded_teams }
    expose(:diff_errors) { diff_errors }
    expose(:rollbar_api) { Api.new }

    after_filter :clean_diff_actor

    def calculate_diff
      self.rollbar_log = []
      diff_status = Rails.cache.fetch('rollbar_performing_teams')
      if diff_status.nil?
        data_guru.refresh
        ::RollbarWorkers::TeamsWorker.perform_later(session[:gh_token])
      elsif diff_status == false
        redirect_to action: :show_diff
      end
    end

    def show_diff
      calculated_diff
      diff_errors
    end

    def sync
      SyncJob.new.perform(AuditedApi.new(rollbar_api, current_user), calculated_diff)
      reset_diff
    end

    def refresh_cache
      reset_diff
      redirect_to rollbar_calculate_diff_path
    end

    def cleanup_teams
      teams_cleanup.now!
    end

    private

    def reset_diff
      Rails.cache.delete 'rollbar_calculated_diff'
      Rails.cache.delete 'rollbar_performing_teams'
      Rails.cache.delete 'rollbar_calculated_teams'
      Rails.cache.delete 'rollbar_diff_errors'
      Rails.cache.delete 'rollbar_cached_invitations'
    end

    def calculated_diff
      Rails.cache.fetch 'rollbar_calculated_diff' do
        @diff ||= Actions::Diff.new(dataguru_teams, rollbar_teams, user_repo)
        @diff.now!
      end
    end

    def diff_errors
      Rails.cache.fetch('rollbar_diff_errors') do
        @diff_errors ||= @diff.errors.uniq.sort { |a, b| a.to_s <=> b.to_s }
      end
    end

    def clean_diff_actor
      @diff.try(:terminate)
    end

    def rollbar_teams
      Rails.cache.fetch('rollbar_calculated_teams')
    end

    def cached_invitations
      Rails.cache.fetch('rollbar_cached_invitations') do
        Actions::ListPendingInvitations.new(rollbar_api).now!
      end
    end
  end
end
