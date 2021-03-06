module GoogleIntegration
  module Actions
    class Diff
      attr_reader :api_groups, :api_users

      def initialize(expected_groups, google_api, user_repo)
        @expected_groups = expected_groups
        @google_api = google_api
        @diff_hash = empty_diff_hash
        @repo = user_repo
      end

      def now!
        generate_diff
        @diff_hash
      end

      def api_groups
        @api_groups ||= @google_api.list_groups_full_info
      end

      def api_users
        @api_users ||= @google_api.list_users.reject { |u| u['suspended'] }
      end

      private

      def empty_diff_hash
        {
          errors: {}, create_groups: {}, add_members: {}, change_privacy: {},
          remove_members: {}, add_aliases: {}, remove_aliases: {},
          add_membership: {}, remove_membership: {}, change_archive: {},
          add_user_aliases: {}, remove_user_aliases: {}
        }
      end

      def generate_diff
        @expected_groups.each do |expected_group|
          google_group = find_or_create_google_group(expected_group)
          add_group_errors(google_group)
          difference_resources(google_group, expected_group)
          domain_membership_diff(google_group, expected_group.domain_membership)
        end
        user_aliases_diff(api_users, @repo)
        @diff_hash[:errors].update @google_api.errors
      end

      def difference_resources(google_group, expected_group)
        privacy_diff(google_group, expected_group)
        archive_diff(google_group, expected_group.archive?)
        members_diff(google_group, expected_group.users(@repo))
        aliases_diff(google_group, expected_group.aliases)
      end

      def add_group_errors(group)
        return if group.errors.blank?
        group.errors.each do |key, errors|
          @diff_hash[:errors][key] = errors
        end
      end

      def privacy_diff(group, expected_group)
        group_privacy = GoogleIntegration::GroupPrivacy.from_google_api(group)
        return unless expected_group.privacy.can_change?
        return if group_privacy == expected_group.privacy

        @diff_hash[:change_privacy][group] = expected_group.privacy
      end

      def archive_diff(group, expected_is_archived)
        return if expected_is_archived.nil?
        return if group.try(:settings).try(:isArchived) == expected_is_archived.to_s

        @diff_hash[:change_archive][group] = expected_is_archived.to_s
      end

      def members_diff(group, expected_members)
        if group.respond_to?(:id)
          add, remove = compute_members(group, expected_members)
          @diff_hash[:add_members][group] = add if add.present?
          @diff_hash[:remove_members][group] = remove if remove.present?
        elsif expected_members.any?
          @diff_hash[:create_groups][group][:add_members] = expected_members
        end
      end

      def compute_members(group, expected_members)
        current_members = list_group_members(group)
        [expected_members - current_members, current_members - expected_members]
      end

      def domain_membership_diff(group, expected_membership)
        if group.respond_to?(:id)
          domain_membership = domain_membership?(group)
          difference_membership(expected_membership, domain_membership, group)
        elsif expected_membership
          @diff_hash[:create_groups][group][:add_membership] = expected_membership
        end
      end

      def difference_membership(expected, domain, group)
        if expected && expected != domain
          @diff_hash[:add_membership][group] = expected
        elsif domain && expected != domain
          @diff_hash[:remove_membership][group] = expected
        end
      end

      # rubocop:disable Metrics/MethodLength
      def user_aliases_diff(google_users, dataguru_users)
        google_users.each do |google_user|
          begin
            dg_user = dataguru_users.find_by_email(google_user['primaryEmail'])
            add, remove = compute_user_aliases(google_user['aliases'] || [],
                                               dg_user.aliases)
            @diff_hash[:add_user_aliases][dg_user] = add
            @diff_hash[:remove_user_aliases][dg_user] = remove
          rescue UserError
            next
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      def compute_user_aliases(google_aliases, dg_aliases)
        google_aliases = google_aliases.map { |a| a.split('@').first }
        [dg_aliases - google_aliases, google_aliases - dg_aliases]
      end

      def aliases_diff(group, aliases)
        aliases ||= []
        if group.respond_to?(:id) # persisted
          add, remove = *compute_aliases(group, aliases)
          @diff_hash[:add_aliases][group] = add if add.present?
          @diff_hash[:remove_aliases][group] = remove if remove.present?
        elsif aliases.present?
          @diff_hash[:create_groups][group][:add_aliases] = aliases
        end
      end

      def compute_aliases(group, aliases)
        current_aliases = list_group_aliases(group['email'])
        [aliases - current_aliases, current_aliases - aliases]
      end

      def domain_membership?(group)
        !group.members.find { |member| member['id'] == AppConfig.google.domain_member_id }.nil?
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
