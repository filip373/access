module GoogleIntegration
  class SessionController < ApplicationController
    include ::GoogleApi

    skip_before_filter :gh_auth_required, only: [:create]
    skip_before_filter :unauthorized_access
    skip_before_filter :google_auth_required

    def new
      session.delete(:credentials)
      Rails.cache.delete('permitted_members')

      redirect_to authorization_uri
    end

    def create
      authorize_auth_client!
      session[:credentials] = {
        client_id: auth_client.client_id,
        access_token: auth_client.access_token,
        redirect_uri: auth_client.redirect_uri,
        token_credential_uri: auth_client.token_credential_uri,
      }
      session[:credentials].merge!(
        email: google_api.user_email,
        is_admin: google_api.admin?
      )
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
        authorization_uri: @auth_client.authorization_uri(
          additional_parameters: { hd: AppConfig.google.main_domain }),
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
  end
end
