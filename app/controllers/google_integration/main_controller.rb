require 'google/api_client'

module GoogleIntegration
  class MainController < ApplicationController
    include ::GoogleApi

    expose(:expected_groups) { GoogleIntegration::Group.all(data_guru.google_groups) }
    expose(:google_log_errors) { log.errors }
    expose(:google_log) { log.log }
    expose(:groups_cleanup) do
      Actions::CleanupGroups.new(expected_groups,
                                 AuditedApi.new(google_api, current_user),
                                 api_groups)
    end
    expose(:missing_groups) { groups_cleanup.stranded_groups }

    expose(:missing_accounts) { calculated_missing_accounts }
    expose(:groups_from_google_api) { api_groups.map { |data| Group.from_google_api(data) } }
    expose(:user_repo) { UserRepository.new(data_guru.members.all) }

    def calculate_diff
      credentials = session[:credentials].each_with_object({}) { |(k, v), h| h[k] = v.to_s }
      CalculateDiffStrategist.new(
        controller: self,
        label: :google,
        data_guru: data_guru,
        session_token: credentials,
      ).call
    end

    def show_diff
    end

    def show_groups
    end

    def refresh_cache
      reset_diff
      redirect_to google_calculate_diff_path
    end

    def sync
      SyncJob.new.perform(AuditedApi.new(google_api, current_user), calculated_diff)
      reset_diff
    end

    def cleanup_groups
      groups_cleanup.now!
    end

    def create_accounts
      created_accounts = Actions::CreateAccounts.new(google_api, user_repo).now!(missing_accounts)
      created_accounts.each do |login, account|
        ::AccountCreationNotifierMailer.new_account(login, account).deliver
      end
      reset_diff
    end

    private

    def reset_diff
      Rails.cache.delete 'google_calculated_diff'
      Rails.cache.delete 'google_calculated_missing_accounts'
      Rails.cache.delete 'google_api_groups'
      Rails.cache.delete 'google_performing_diff'
    end

    def calculated_diff
      build_cached_diff
    end

    def build_cached_diff
      {
        errors: Rails.cache.read('google_diff_errors'),
        create_groups: Rails.cache.read('google_diff_create_groups'),
        add_members: Rails.cache.read('google_diff_add_members'),
        change_privacy: Rails.cache.read('google_diff_change_privacy'),
        remove_members: Rails.cache.read('google_diff_remove_members'),
        add_aliases: Rails.cache.read('google_diff_add_aliases'),
        remove_aliases: Rails.cache.read('google_diff_remove_aliases'),
        add_membership: Rails.cache.read('google_diff_add_membership'),
        remove_membership: Rails.cache.read('google_diff_remove_membership'),
        change_archive: Rails.cache.read('google_diff_change_archive'),
        add_user_aliases: Rails.cache.read('google_diff_add_user_aliases'),
        remove_user_aliases: Rails.cache.read('google_diff_remove_user_aliases'),
      }
    end

    def prepare_sync
      api_groups
    end

    def api_groups
      Rails.cache.fetch 'google_api_groups' do
        google_api.list_groups_full_info
      end
    end

    def calculated_missing_accounts
      Rails.cache.fetch 'google_calculated_missing_accounts' do
        Actions::AccountsDiff.new(google_api, user_repo).now!
      end
    end

    def log
      return @log if @log.present?
      @log = Actions::Log.new(calculated_diff)
      @log.generate_log
      @log
    end
  end
end
