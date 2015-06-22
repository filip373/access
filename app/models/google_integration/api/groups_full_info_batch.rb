class GoogleIntegration::Api
  class GroupsFullInfoBatch
    attr_reader :initial_groups, :google_groups, :groups_settings_api, :directory_api, :client
    attr_accessor :groups_to_retry
    private :initial_groups, :groups_to_retry

    def initialize(initial_groups, groups_settings_api, directory_api, client)
      @initial_groups = initial_groups.map { |group| Hashie::Mash.new group }
      @groups_settings_api = groups_settings_api
      @directory_api = directory_api
      @client = client
      @google_groups = []
      @groups_to_retry = []
    end

    def execute!
      @google_groups = collect_groups_full_info!(initial_groups)
    end

    def retry_fetch!
      return unless general_error?
      collect_groups_full_info!(groups_to_retry)
      groups_to_retry.each { |group| find_group(group).update group }
    end

    def general_error
      return unless general_error?
      %(
        we couldn't retrive full info from the google api.
        Affected groups: #{groups_to_retry.map { |group| group['name'] }.join(', ')}.
            )
    end

    def general_error?
      groups_to_retry.present?
    end

    private

    def find_group(group)
      google_groups.find { |group_data| group_data.name == group.name }
    end

    def collect_groups_full_info!(groups)
      batch = Google::APIClient::BatchRequest.new
      @groups_to_retry = []

      data = groups.map do |group|
        members_list_batch_request!(group, batch)
        group_settings_batch_request!(group, batch)
        group
      end

      client.execute(batch)
      data
    end

    def group_settings_batch_request!(group, batch)
      return if group[:settings].present?
      group[:errors] = nil

      batch.add(group_settings_request(group)) do |result|
        body = Hash.from_xml(result.body) || {}
        add_groups_error(group, body['errors'])
        group[:settings] = body['entry'] || {}
      end
    end

    def members_list_batch_request!(group, batch)
      return if group[:members].present?
      group[:errors] = nil

      batch.add(members_list_request(group)) do |result|
        body = JSON.parse(result.body) || {}

        add_members_error(group, body['error'])
        group[:members] = body['members'] || []
      end
    end

    def add_groups_error(group, errors)
      return if errors.blank?

      group[:errors] =  { settings: errors['error']['internalReason'] }
      groups_to_retry.push group
    end

    def add_members_error(group, errors)
      return if errors.blank?

      message = errors['errors'].map { |error| error['message'] }.join(', ')
      group[:errors] = { members: message }
      groups_to_retry.push group
    end

    def group_settings_request(group)
      { api_method: groups_settings_api.groups.get,
        parameters: { 'groupUniqueId' => group['email'] } }
    end

    def members_list_request(group)
      { api_method: directory_api.members.list,
        parameters: { 'groupKey' => group['id'] } }
    end
  end
end
