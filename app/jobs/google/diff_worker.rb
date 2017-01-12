module GoogleWorkers
  class DiffWorker < Base
    def perform(session_token)
      @session_token = session_token
      set_performing_flag
      calculate_diff
      unset_performing_flag
    end

    def self.applicable_to?(label)
      label == :google
    end

    private

    def set_performing_flag
      Rails.cache.write('google_performing_diff', true)
    end

    def calculate_diff
      diff = GoogleIntegration::Actions::Diff.new(expected_groups, google_api, user_repo).now!
      store_diff_in_cache(diff)
    end

    def unset_performing_flag
      Rails.cache.write('google_performing_diff', false)
    end

    # rubocop:disable Metrics/MethodLength
    def store_diff_in_cache(diff)
      Rails.cache.write('google_diff_errors', diff[:errors])
      Rails.cache.write('google_diff_create_groups', diff[:create_groups])
      Rails.cache.write('google_diff_add_members', diff[:add_members])
      Rails.cache.write('google_diff_change_privacy', diff[:change_privacy])
      Rails.cache.write('google_diff_remove_members', diff[:remove_members])
      Rails.cache.write('google_diff_add_aliases', diff[:add_aliases])
      Rails.cache.write('google_diff_remove_aliases', diff[:remove_aliases])
      Rails.cache.write('google_diff_add_membership', diff[:add_membership])
      Rails.cache.write('google_diff_remove_membership', diff[:remove_membership])
      Rails.cache.write('google_diff_change_archive', diff[:change_archive])
      Rails.cache.write('google_diff_add_user_aliases', diff[:add_user_aliases])
      Rails.cache.write('google_diff_remove_user_aliases', diff[:remove_user_aliases])
    end
    # rubocop:enable Metrics/MethodLength
  end
end
