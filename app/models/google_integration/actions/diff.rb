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
          add_membership: {},
          remove_membership: {}
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
          domain_membership_diff(google_group, expected_group.domain_membership)
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

      def domain_membership_diff(group, expected_membership)
        if group.respond_to?(:id)
          domain_membership = check_domain_membership(group['id'])

          if expected_membership && expected_membership != domain_membership
            @diff_hash[:add_membership][group] = expected_membership
          elsif domain_membership && expected_membership != domain_membership
            @diff_hash[:remove_membership][group] = expected_membership
          end
        elsif expected_membership.present?
          @diff_hash[:create_groups][group][:add_membership] = expected_membership
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
        elsif aliases.present?
          @diff_hash[:create_groups][group][:add_aliases] = aliases
        end
      end

      def check_domain_membership(group_id)
        return true if members_list(group_id).find do |member|
          member['id'] == AppConfig.google.domain_member_id
        end
      end

      def list_group_members(group_id)
        members_list(group_id).map { |m| m['email'] }.compact
      end

      def members_list(group_id)
        return @members_list if @group_id == group_id
        @group_id = group_id
        @members_list = @google_api.list_members(group_id)
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
