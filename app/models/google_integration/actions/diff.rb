module GoogleIntegration
  module Actions
    class Diff
      def initialize(expected_groups, google_api)
        @expected_groups = expected_groups
        @google_api = google_api
        @diff_hash = {
          create_groups: {},
          add_members: {},
          remove_members: {},
          add_aliases: {},
          remove_aliases: {},
        }
      end

      def now!
        generate_diff
        @diff_hash
      end

      private

      def generate_diff
        @expected_groups.each do |expected_group|
          google_group = find_or_create_google_group(expected_group)
          members_diff(google_group, expected_group.users)
          aliases_diff(google_group, expected_group.aliases)
        end
      end

      def members_diff(group, expected_members)
        if group.respond_to?(:id)
          current_members = list_group_members(group['id'])
          add = expected_members - current_members
          remove = current_members - expected_members
          @diff_hash[:add_members][group] = add if add.present?
          @diff_hash[:remove_members][group] = remove if remove.present?
        else
          if expected_members.present?
            @diff_hash[:create_groups][group][:add_members] = expected_members
          end
        end
      end

      def aliases_diff(group, aliases)
        aliases ||= []
        if group.respond_to?(:id) # persisted
          current_aliases = list_group_aliases(group['email'])
          add = aliases - current_aliases
          remove = current_aliases - aliases
          @diff_hash[:add_aliases][group] = add if add.present?
          @diff_hash[:remove_aliases][group] = remove if remove.present?
        else
          if aliases.present?
            @diff_hash[:create_groups][group][:add_aliases] = aliases
          end
        end
      end

      def list_group_members(group_id)
        @google_api.list_members(group_id).map { |m| m['email'] }.compact
      end

      def list_group_aliases(name)
        name = Helpers::User.email_to_username(name)
        aliases = find_group(name).fetch('aliases', [])
        aliases.map { |e| Helpers::User.email_to_username(e) }
      end

      def find_group(group_name)
        api_groups.find { |g| Helpers::User.email_to_username(g.email) == group_name.downcase }
      end

      def api_groups
        @api_groups ||= @google_api.list_groups
      end

      def find_or_create_google_group(expected_group)
        group = find_group(expected_group.name)
        return group unless group.nil?
        @diff_hash[:create_groups][expected_group] = {}
        expected_group
      end
    end
  end
end
