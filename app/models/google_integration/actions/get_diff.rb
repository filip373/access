module GoogleIntegration
  module Actions
    class GetDiff
      include GoogleHelper

      def initialize(expected_groups, google_api)
        @expected_groups = expected_groups
        @google_api = google_api
        @diff_hash = {
          create_groups: {},
          add_members: {},
          remove_members: {},
          add_aliases: {},
          remove_aliases: {}
        }
      end

      def now!
        generate_diff
        @diff_hash
      end

      private

      def generate_diff
        @expected_groups.each do |expected_group|
          members = map_members_to_mails(expected_group.members)
          google_group = find_or_create_google_group(expected_group)

          members_diff(google_group, members)
          aliases_diff(google_group, group_data.aliases)
        end
      end

      def members_diff(group, members_mails)
        if group.respond_to?(:id)
          current_members_mails = group.respond_to?(:fake) ? [] : list_group_members(group['id'])
          add = members_mails - current_members_mails
          remove = current_members_mails - members_mails
          @diff_hash[:add_members][group] = add if add.size > 0
          @diff_hash[:remove_members][group] = remove if remove.size > 0
        else
          @diff_hash[:create_groups][group][:add_members] = members_mails unless members_mails.empty?
        end
      end

      def aliases_diff(group, aliases)
        if group.respond_to?(:id)
          current_aliases = group.respond_to?(:fake) ? [] : list_group_aliases(group['name'])
          add = aliases - current_aliases
          remove = current_aliases - aliases
          @diff_hash[:add_aliases][group] = add if add.size > 0
          @diff_hash[:remove_aliases][group] = remove if remove.size > 0
        else
          @diff_hash[:create_groups][group][:add_aliases] = aliases unless aliases.empty?
        end
      end

      def list_group_members(group_id)
        @google_api.list_members(group_id).map{ |m| m['email'] }
      end

      def list_group_aliases(name)
        aliases = get_groups.find { |g| g.name == name }["aliases"]
        aliases.map { |a| a.values }.flatten
      end

      def get_group(group_name)
        get_groups.find { |g| g.name.downcase == group_name.downcase }
      end

      def get_groups
        @groups ||= @google_api.list_groups
      end

      def find_or_create_google_group(expected_group)
        group = get_group(expected_group.name)
        return group unless group.nil?
        @diff_hash[:create_groups][expected_group] = {}
        expected_group
      end

      def map_members_to_mails(members)
        members.map do |m|
          user = User.find(m)
          raise "Unknown user #{m}" if user.nil?
          user_mail(user)
        end
      end
    end
  end
end
