module GoogleIntegration
  module Actions
    class AccountsDiff
      def initialize(google_api)
        @google_api = google_api
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
        User.list_company_users.keys
      end
    end
  end
end
