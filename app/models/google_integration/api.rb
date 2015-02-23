module GoogleIntegration
  class Api
    attr_accessor :token

    BASE_URL = 'https://www.googleapis.com:443'
    EMAIL_SETTINGS_API = 'https://apps-apis.google.com/a/feeds/emailsettings/2.0'

    def initialize(token)
      self.token = token
    end

    # groups

    def add_member(group_id, user_email)
      post "groups/#{group_id}/members", email: user_email, role: 'MEMBER'
    end

    def remove_member(group_id, user_email)
      delete "groups/#{group_id}/members/#{user_email}"
    end

    def list_members(group_id)
      data = get "groups/#{group_id}/members"
      (data['members'] || [])
    end

    def list_groups
      data = get 'groups', domain: AppConfig.google.main_domain
      data['groups'].map { |e| Hashie::Mash.new(e) }
    end

    def create_group(name)
      post 'groups',
           email: name,
           name: "Project group - #{name}"
    end

    def remove_group(group_id)
      delete "groups/#{group_id}"
    end

    def add_alias(group_id, google_alias)
      post "groups/#{group_id}/aliases", alias: google_alias
    end

    def remove_alias(group_id, google_alias)
      delete "groups/#{group_id}/aliases/#{google_alias}"
    end

    # user

    def reset_password(user_email, password)
      put "users/#{user_email}",
          password: password,
          changePasswordAtNextLogin: true
    end

    def create_user(params)
      post 'users',
           name: {
             familyName: params[:last_name],
             givenName: params[:first_name],
           },
           primaryEmail: params[:email],
           password: params[:password]
    end

    private

    def post(path, body)
      response = api.post "#{BASE_URL}/admin/directory/v1/#{path}",
                          body: body.to_json,
                          headers: { 'Content-Type' => 'application/json' }
      response.body.present? ? JSON.parse(response.body) : {}
    end

    def put(path, body)
      response = api.put "#{BASE_URL}/admin/directory/v1/#{path}",
                         body: body.to_json,
                         headers: { 'Content-Type' => 'application/json' }
      response.body.present? ? JSON.parse(response.body) : {}
    end

    def get(path, query = {})
      response = api.get "#{BASE_URL}/admin/directory/v1/#{path}",
                         params: query,
                         headers: { 'Content-Type' => 'application/json' }
      JSON.parse response.body
    end

    def delete(path)
      response = api.delete "#{BASE_URL}/admin/directory/v1/#{path}",
                            headers: { 'Content-Type' => 'application/json' }
      response.body.present? ? JSON.parse(response.body) : {}
    end

    def api
      @api ||= OAuth2::AccessToken.new(client, token)
    end

    def client
      @client ||= OAuth2::Client.new(
        AppConfig.google.client_id,
        AppConfig.google.client_secret,
        site: 'https://accounts.google.com',
        authorize_url: '/o/oauth2/auth',
        token_url: '/o/oauth2/token',
      )
    end
  end
end
