module GoogleIntegration
  module Actions
    class Diff
      attr_reader :api_groups

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
          remove_membership: {},
          change_archive: {},
          change_privacy: {},
        }
      end

      def now!
        generate_diff
        @diff_hash
      end

      def api_groups
        @api_groups ||= @google_api.list_groups_full_info
      end

      private

      def generate_diff
        @expected_groups.each do |expected_group|
          google_group = find_or_create_google_group(expected_group)
          privacy_diff(google_group, expected_group)
          archive_diff(google_group, expected_group.archive?)
          members_diff(google_group, expected_group.users)
          aliases_diff(google_group, expected_group.aliases)
          domain_membership_diff(google_group, expected_group.domain_membership)
        end
      end

      def privacy_diff(group, expected_group)
        google_group_settings = Hashie::Mash.new(
          show_in_group_directory: group.try(:settings).try(:showInGroupDirectory),
          who_can_view_group: group.try(:settings).try(:whoCanViewGroup)
        )
        expected_settings = Hashie::Mash.new(
          show_in_group_directory: expected_group.show_in_group_directory?.to_s,
          who_can_view_group: expected_group.who_can_view_group
        )

        if google_group_settings != expected_settings
          @diff_hash[:change_privacy][group] =
            GoogleIntegration::GroupPrivacy.new(expected_settings)
        end
      end

      def archive_diff(group, expected_is_archived)
        if group.try(:settings).try(:isArchived) != expected_is_archived.to_s
          @diff_hash[:change_archive][group] = expected_is_archived.to_s
        end
      end

      def members_diff(group, expected_members)
        if group.respond_to?(:id)
          current_members = list_group_members(group)
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
          domain_membership = domain_membership?(group)

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

      def domain_membership?(group)
        !!group.members.find { |member| member['id'] == AppConfig.google.domain_member_id }
      end

      def list_group_members(group)
        group.members.map { |m| m['email'] }.compact
      end

      def list_group_aliases(name)
        name = Helpers::User.email_to_username(name)
        aliases = find_group(name).fetch('aliases', [])
        aliases.map { |e| Helpers::User.email_to_username(e) }
      end

      def find_group(group_name)
        api_groups.find { |g| Helpers::User.email_to_username(g.email) == group_name.downcase }
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
