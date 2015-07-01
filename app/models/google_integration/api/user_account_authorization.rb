class GoogleIntegration::Api
  class UserAccountAuthorization < AuthorizationAbstract
    def authorize!
      client
    end

    private

    def client
      @client ||= Signet::OAuth2::Client.new(credentials)
    end
  end
end
