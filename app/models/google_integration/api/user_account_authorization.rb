class GoogleIntegration::Api
  class UserAccountAuthorization < AuthorizationAbstract
    delegate :access_token, to: :client

    def authorize!
      client
    end

    private

    def client
      @client ||= Signet::OAuth2::Client.new(credentials)
    end

    def user_info_uri(access_token)
      "https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=#{access_token}"
    end
  end
end
