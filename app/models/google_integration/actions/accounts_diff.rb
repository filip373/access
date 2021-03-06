module GoogleIntegration
  module Actions
    class AccountsDiff
      def initialize(google_api, user_repo)
        @google_api = google_api
        @repo = user_repo
      end

      def now!
        generate_diff
      end

      private

      def generate_diff
        expected_accounts - google_accounts
      end

      def google_accounts
        @google_api.list_users.map do |account|
          Helpers::User.email_to_username(account['primaryEmail'])
        end.compact
      end

      def expected_accounts
        @repo.list_company_users.map do |user|
          Helpers::User.email_to_username(user.emails.first) || user.id
        end
      end
    end
  end
end
