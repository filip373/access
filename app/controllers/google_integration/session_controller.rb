module GoogleIntegration
  class SessionController < ApplicationController
    skip_before_filter :gh_auth_required, only: [:create]
    skip_before_filter :google_auth_required, only: [:create]

    def new
      redirect_to authorization_uri
    end

    def create
      authorize_auth_client!
      session[:credentials] = auth_client_json
      redirect_to google_show_diff_path
    end

    private

    def authorization_uri
      auth_client.authorization_uri.to_s
    end

    def auth_client
      return @auth_client if @auth_client.present?
      @auth_client = client_secrets.to_authorization
      @auth_client.update!(
        scope: AppConfig.google.scope,
      )
      @auth_client
    end

    def client_secrets
      google_secrets = AppConfig.google
      ::Google::APIClient::ClientSecrets.new(
        flow: :web,
        web: {
          client_id: google_secrets.client_id,
          client_secret: google_secrets.client_secret,
          redirect_uri: google_oauth2_callback_url,
        },
      )
    end

    def authorize_auth_client!
      auth_client.code = request['code']
      auth_client.fetch_access_token!
    end

    def auth_client_json
      auth_client_json = JSON.parse(auth_client.to_json)
      auth_client_json['redirect_uri'] = auth_client.redirect_uri.to_s
      auth_client_json['client_secret'] = nil
      auth_client_json.compact.to_json
    end
  end
end
