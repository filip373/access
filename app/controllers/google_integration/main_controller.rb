require 'google/api_client'

module GoogleIntegration
  class MainController < ApplicationController
    include ::GoogleApi

    expose(:expected_groups) { Groups.all(data_guru.google_groups) }
    expose(:google_log_errors) { log.errors }
    expose(:google_log) { log.log }
    expose(:groups_cleanup) do
      Actions::CleanupGroups.new(expected_groups, google_api, api_groups)
    end
    expose(:missing_groups) { groups_cleanup.stranded_groups }

    expose(:missing_accounts) { calculated_missing_accounts }
    expose(:groups_from_google_api) { api_groups.map { |data| Group.from_google_api(data) } }
    expose(:user_repo) { UserRepository.new(data_guru.users) }

    def show_diff
      reset_diff
      data_guru.refresh
    end

    def show_groups
    end

    def sync
      SyncJob.new.perform(google_api, calculated_diff)
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
    end

    def calculated_diff
      Rails.cache.fetch 'google_calculated_diff' do
        @google_diff ||= Actions::Diff.new(expected_groups, google_api, user_repo)
        @google_diff.now!
      end
    end

    def prepare_sync
      calculated_diff
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
