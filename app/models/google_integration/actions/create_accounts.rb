module GoogleIntegration
  module Actions
    class CreateAccounts
      def initialize(google_api)
        @google_api = google_api
        @create_accounts = {}
      end

      def now!(accounts)
        create_accounts(accounts)
        @create_accounts
      end

      private

      def create_accounts(accounts)
        accounts.each do |login|
          create_account(login)
          sleep(5)
          generate_codes(login)
          sleep(5)
          reset_password(login)
          sleep(10)
          @create_accounts[login][:codes] = get_codes(login).take(3)
          sleep(10)
          post_filters(login)
        end
      end

      def create_account(login)
        user = User.find(login)
        params = {
          first_name: user.name.split(' ').first,
          last_name: user.name.split(' ').last,
          email: "#{login}@#{AppConfig.google.main_domain}",
          password: SecureRandom.hex(8),
          login: login,
        }
        @google_api.create_user(params)
        @create_accounts[login] = params
      end

      def generate_codes(login)
        @google_api.generate_codes(@create_accounts[login][:email])
      end

      def reset_password(login)
        @google_api.reset_password(
          @create_accounts[login][:email],
          @create_accounts[login][:password],
        )
      end

      def get_codes(login)
        @google_api.get_codes(@create_accounts[login][:email])
      end

      def post_filters(login)
        @google_api.post_filters(login)
      end
    end
  end
end
