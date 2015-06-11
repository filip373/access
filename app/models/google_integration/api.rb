require 'google/api_client'
require 'google/api_client/client_secrets'

module GoogleIntegration
  class Api
    def initialize(credentials)
      authorize_client(credentials)
    end

    # groups

    def add_member(group_id, user_email)
      post "groups/#{group_id}/members", email: user_email, role: 'MEMBER'
    end

    def remove_member(group_id, user_email)
      delete "groups/#{group_id}/members/#{user_email}"
    end

    def set_domain_membership(group_id)
      post "groups/#{group_id}/members",
           id: AppConfig.google.domain_member_id,
           role: 'MEMBER'
    end

    def unset_domain_membership(group_id)
      delete "groups/#{group_id}/members/#{AppConfig.google.domain_member_id}"
    end

    def list_groups
      @groups ||= request(directory.groups.list, domain: AppConfig.google.main_domain).fetch('groups')
    end

    def list_groups_with_members
      batch = Google::APIClient::BatchRequest.new
      groups_data = list_groups.map do |group|
        batch_request = { api_method: directory.members.list,
                          parameters: { 'groupKey' => group['id'] },
                          headers: { 'Content-Type' => 'application/json' } }
        batch.add(batch_request) do |result|
          group[:members] = JSON.parse(result.body)['members'] || []
        end
        group
      end
      client.execute(batch)
      groups_data.map { |group| Hashie::Mash.new(group) }
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

    def request(path, parameters)
      result = client.execute(api_method: path,
                              parameters: parameters,
                             )
      JSON.parse(result.response.body)
    end

    def delete(path)
      response = api.delete "#{BASE_URL}/admin/directory/v1/#{path}",
                            headers: { 'Content-Type' => 'application/json' }
      response.body.present? ? JSON.parse(response.body) : {}
    end

    def client
      @client = ::Google::APIClient.new(application_name: 'access')
    end

    def directory
      @directory ||= client.discovered_api('admin', 'directory_v1')
    end

    def authorize_client(credentials)
      client_opts = JSON.parse(credentials)
      client.authorization = ::Signet::OAuth2::Client.new(client_opts)
    end
  end
end
