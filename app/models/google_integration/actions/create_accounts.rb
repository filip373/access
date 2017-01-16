module GoogleIntegration
  module Actions
    class CreateAccounts
      def initialize(google_api, user_repo)
        @google_api = google_api
        @create_accounts = {}
        @repo = user_repo
      end

      def now!(accounts)
        create_accounts(accounts)
        @create_accounts
      end

      private

      def create_accounts(accounts)
        accounts.each do |login|
          call_and_sleep(5) { create_account(login) }
          call_and_sleep(5) { generate_codes(login) }
          call_and_sleep(10) { reset_password(login) }
          @create_accounts[login][:codes] = call_and_sleep(10) { get_codes(login).take(3) }
          post_filters(login)
        end
      end

      def call_and_sleep(time, &block)
        sleep(time)
        block.call if block_given?
      end

      def create_account(login)
        user = @repo.find(login)
        params = {
          first_name: user.name.split(' ').first,
          last_name: user.name.split(' ').last,
          email: "#{login}@#{AppConfig.google.main_domain}",
          password: AppConfig.google.new_user_password,
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
