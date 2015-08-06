class GoogleIntegration::Api
  class ServiceAccountAuthorization < AuthorizationAbstract
    delegate :access_token, to: :client

    def authorize!
      client.fetch_access_token!
      client
    end

    private

    def client
      @client ||= Signet::OAuth2::Client.new(
        token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
        audience: 'https://accounts.google.com/o/oauth2/token',
        scope: AppConfig.google.scope,
        issuer: AppConfig.google.service_account_email,
        signing_key: p12_key,
        sub: AppConfig.google.supporter_email,
      )
    end

    def p12_key
      Google::APIClient::KeyUtils.load_from_pkcs12(
        Rails.root.join(AppConfig.google.p12_key_path),
        AppConfig.google.p12_key_secret,
      )
    end
  end
end
