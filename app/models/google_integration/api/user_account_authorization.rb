class GoogleIntegration::Api
  class UserAccountAuthorization < AuthorizationAbstract
    def authorize!
      client
    end

    def email
      user_info.email
    end

    def user_info
      return @user_info if @user_info.present?
      response = client.fetch_protected_resource(
        uri: user_info_uri(client.access_token)
      )
      @user_info = Hashie::Mash.new(JSON.parse(response.body))
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
