require 'google/api_client'
require 'google/api_client/client_secrets'

module GoogleIntegration
  class Api
    attr_reader :errors

    def initialize(credentials)
      authorize_client(credentials)
      @errors = {}
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
      return @groups_data.google_groups if @groups_data.present?
      @groups_data =
        GroupsFullInfoBatch.new(list_groups, groups_settings_api, directory_api, client)
      @groups_data.execute!

      retry_count = 10
      while retry_count > 0 && @groups_data.retry_fetch! do retry_count -= 1 end

      add_general_error @groups_data.general_error if @groups_data.general_error?

      @groups_data.google_groups
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

    def change_group_privacy_setting(group, privacy)
      request(
        api_method: groups_settings_api.groups.update,
        parameters: { 'groupUniqueId' => group.email },
        body_object: privacy,
      )
    end

    def change_group_archive_setting(group, flag)
      request(
        api_method: groups_settings_api.groups.update,
        parameters: { 'groupUniqueId' => group.email },
        body_object: { isArchived: flag },
      )
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
      @client ||= ::Google::APIClient.new(
        application_name: AppConfig.google.application_name,
        application_version: AppConfig.google.application_version,
      )
    end

    def groups_settings_api
      Rails.cache.fetch 'groups_settings_api' do
        client.discovered_api('groupssettings')
      end
    end

    def directory_api
      Rails.cache.fetch 'directory_api' do
        client.discovered_api('admin', 'directory_v1')
      end
    end

    def authorize_client(credentials)
      client.authorization = ::Signet::OAuth2::Client.new(credentials)
    end

    def add_general_error(error_message)
      errors[:general] = error_message
    end
  end
end
