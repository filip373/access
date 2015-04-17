module GoogleIntegration
  module Actions
    class Sync
      def initialize(google_api)
        @google_api = google_api
      end

      def now!(diff)
        sync(diff)
      end

      private

      def sync(diff)
        create_groups(diff[:create_groups])
        sync_members(diff[:add_members], diff[:remove_members]) if diff[:remove_members]
        sync_aliases(diff[:add_aliases], diff[:remove_aliases]) if diff[:remove_aliases]
      end

      def sync_members(members_to_add, members_to_remove)
        members_to_remove.each do |group, members|
          members.each do |member|
            remove_member(group, member)
          end
        end

        members_to_add.each do |group, members|
          add_members(group, members)
        end
      end

      def sync_aliases(aliases_to_add, aliases_to_remove)
        aliases_to_add.each do |group, aliases|
          add_aliases(group, aliases)
        end

        aliases_to_remove.each do |group, aliases|
          aliases.each do |google_alias|
            remove_alias(group, google_alias)
          end
        end
      end

      def create_groups(groups_to_create)
        groups_to_create.each do |group, h|
          @google_api.create_group(group.email)
          add_members(group, h[:add_members]) if h[:add_members]
          add_aliases(group, h[:add_aliases]) if h[:add_aliases]
        end
      end

      def remove_alias(group, google_alias)
        @google_api.remove_alias(group.email, Helpers::User.username_to_email(google_alias))
      end

      def remove_member(group, member)
        @google_api.remove_member(group.email, member)
      end

      def add_members(group, members)
        members.each do |member|
          @google_api.add_member(group.email, member)
        end
      end

      def add_aliases(group, aliases)
        aliases.each do |google_alias|
          @google_api.add_alias(group.email, Helpers::User.username_to_email(google_alias))
        end
      end
    end
  end
end
