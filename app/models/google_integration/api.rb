module GoogleIntegration
  class Api
    attr_accessor :token

    BASE_URL = 'https://www.googleapis.com:443'
    EMAIL_SETTINGS_API = 'https://apps-apis.google.com/a/feeds/emailsettings/2.0'

    def initialize(token)
      self.token = token
    end

    # groups

    def add_member(group, user_email)
      post "groups/#{group}/members", email: user_email, role: 'MEMBER'
    end

    def remove_member(group, user_email)
      delete "groups/#{group}/members/#{user_email}"
    end

    def list_members(group)
      data = get "groups/#{group}/members"
      (data['members'] || [])
    end

    def list_groups
      data = get 'groups', domain: AppConfig.google.main_domain
      data['groups'].map { |e| Hashie::Mash.new(e) }
    end

    def create_group(name)
      response = post 'groups',
                      email: name,
                      name: "Project group - #{name}",
                      description: "Project group for #{name}"
      yield(response) if block_given?
    end

    def add_alias(group, google_alias)
      post "groups/#{group.id}/aliases", alias: google_alias
    end

    def remove_alias(group, google_alias)
      delete "groups/#{group.id}/aliases/#{google_alias}"
    end

    # user

    def reset_password(user_email, password)
      put "users/#{user_email}",
          password: password,
          changePasswordAtNextLogin: true
    end

    def generate_codes(user_email)
      post "users/#{user_email}/verificationCodes/generate", {}
    end

    def get_codes(user_email)
      data = get("users/#{user_email}/verificationCodes")
      data['items'].map { |e| e['verificationCode'] }
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

    def post_filters(email)
      username = email.split('@').first
      Dir.glob("#{Rails.root}/static_data/gmail_filters/*").each do |filter|
        filter = File.read(filter)
        api.post "#{EMAIL_SETTINGS_API}/netguru.pl/#{username}/filter",
                 body: filter,
                 headers: { 'Content-Type' => 'application/atom+xml' }
      end
    end

    def put_spam(group_email)
      body = {
        'kind' => 'groupsSettings#groups',
        'spamModerationLevel' => 'ALLOW',
      }
      response = api.put "#{BASE_URL}/groups/v1/groups/#{group_email}",
                         body: body.to_json,
                         headers: { 'Content-Type' => 'application/json' }
      response.body.present? ? JSON.parse(response.body) : {}
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
