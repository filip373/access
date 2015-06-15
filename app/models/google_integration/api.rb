require 'google/api_client'
require 'google/api_client/client_secrets'

module GoogleIntegration
  class Api
    def initialize(credentials)
      authorize_client(credentials)
    end

    # groups

    def add_member(group_id, user_email)
      request(
        api_method: directory.members.insert,
        parameters: { groupKey: group_id },
        body_object: { email: user_email, role: 'MEMBER' },
      )
    end

    def remove_member(group_id, user_email)
      request(
        api_method: directory.members.delete,
        parameters: { groupKey: group_id, memberKey: user_email },
      )
    end

    def set_domain_membership(group_id)
      request(
        api_method: directory.members.insert,
        parameters: { groupKey: group_id },
        body_object: { id: AppConfig.google.domain_member_id, role: 'MEMBER' },
      )
    end

    def unset_domain_membership(group_id)
      request(
        api_method: directory.members.delete,
        parameters: { groupKey: group_id, memberKey: AppConfig.google.domain_member_id },
      )
    end

    def list_groups
      @groups ||= request(
        api_method: directory.groups.list,
        parameters: { domain: AppConfig.google.main_domain },
      ).fetch('groups')
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
      request(
        api_method: directory.groups.insert,
        body_object: { email: name, name: "Project group - #{name}" },
      )
    end

    def remove_group(group_id)
      request(
        api_method: directory.groups.delete,
        parameters: { groupKey: group_id },
      )
    end

    def add_alias(group_id, google_alias)
      request(
        api_method: directory.groups.aliases.insert,
        parameters: { groupKey: group_id },
        body_object: { alias: google_alias },
      )
    end

    def remove_alias(group_id, google_alias)
      request(
        api_method: directory.groups.aliases.delete,
        parameters: { groupKey: group_id, alias: google_alias },
      )
    end

    # user

    def reset_password(user_email, password)
      request(
        api_method: directory.users.patch,
        parameters: { userKey:  user_email },
        body_object: {
          password: password,
          changePasswordAtNextLogin: true,
        },
      )
    end

    def create_user(params)
      request(
        api_method: directory.users.insert,
        body_object: {
          name: {
            familyName: params[:last_name],
            givenName: params[:first_name],
          },
          primaryEmail: params[:email],
          password: params[:password],
        },
      )
    end

    private

    def request(params)
      result = client.execute(params)
      JSON.parse(result.response.body) if result.response.body.present?
    end

    def client
      @client ||= ::Google::APIClient.new(application_name: 'access')
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
