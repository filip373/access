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
        api_method: directory_api.members.insert,
        parameters: { groupKey: group_id },
        body_object: { email: user_email, role: 'MEMBER' },
      )
    end

    def remove_member(group_id, user_email)
      request(
        api_method: directory_api.members.delete,
        parameters: { groupKey: group_id, memberKey: user_email },
      )
    end

    def set_domain_membership(group_id)
      request(
        api_method: directory_api.members.insert,
        parameters: { groupKey: group_id },
        body_object: { id: AppConfig.google.domain_member_id, role: 'MEMBER' },
      )
    end

    def unset_domain_membership(group_id)
      request(
        api_method: directory_api.members.delete,
        parameters: { groupKey: group_id, memberKey: AppConfig.google.domain_member_id },
      )
    end

    def list_groups
      @groups ||= request(
        api_method: directory_api.groups.list,
        parameters: { domain: AppConfig.google.main_domain },
      ).fetch('groups')
    end

    def list_groups_full_info
      batch = Google::APIClient::BatchRequest.new
      groups_data = list_groups.map do |group|
        batch.add(members_list_request(group)) do |result|
          group[:members] = JSON.parse(result.body)['members'] || []
        end
        batch.add(group_settings_request(group)) do |result|
          group[:settings] = Hash.from_xml(result.body)['entry'] || []
        end
        group
      end
      client.execute(batch)
      groups_data.map { |group| Hashie::Mash.new(group) }
    end

    def group_settings_request(group)
      { api_method: groups_settings_api.groups.get,
        parameters: { 'groupUniqueId' => group['email'] } }
    end

    def members_list_request(group)
      { api_method: directory_api.members.list,
        parameters: { 'groupKey' => group['id'] } }
    end

    def create_group(name)
      request(
        api_method: directory_api.groups.insert,
        body_object: { email: name, name: "Project group - #{name}" },
      )
    end

    def remove_group(group_id)
      request(
        api_method: directory_api.groups.delete,
        parameters: { groupKey: group_id },
      )
    end

    def add_alias(group_id, google_alias)
      request(
        api_method: directory_api.groups.aliases.insert,
        parameters: { groupKey: group_id },
        body_object: { alias: google_alias },
      )
    end

    def remove_alias(group_id, google_alias)
      request(
        api_method: directory_api.groups.aliases.delete,
        parameters: { groupKey: group_id, alias: google_alias },
      )
    end

    def change_group_archive_setting(group, flag)
      request groups_settings_api.groups.update,
        { 'groupUniqueId' => group.email },
        { isArchived: flag }.to_json
    end

    # user

    def reset_password(user_email, password)
      request(
        api_method: directory_api.users.patch,
        parameters: { userKey:  user_email },
        body_object: {
          password: password,
          changePasswordAtNextLogin: true,
        },
      )
    end

    def create_user(params)
      request(
        api_method: directory_api.users.insert,
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

    def groups_settings_api
      @groups_settings_api ||= client.discovered_api('groupssettings')
    end

    def directory_api
      @directory_api ||= client.discovered_api('admin', 'directory_v1')
    end

    def authorized_client(creds = nil)
      return @authorized_client if @authorized_client.present?
      @authorized_client = ::Signet::OAuth2::Client.new(creds)
    end

    def authorize_client(credentials)
      client_opts = JSON.parse(credentials)
      client.authorization = authorized_client(client_opts.symbolize_keys)
    end
  end
end
