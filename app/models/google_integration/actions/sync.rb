module GoogleIntegration
  module Actions
    class Sync
      def initialize(google_api)
        @google_api = google_api
      end

      # rubocop:disable Metrics/AbcSize
      def now!(diff)
        create_groups(Array(diff[:create_groups]))
        sync_groups_archive_settings(Array(diff[:change_archive]))
        sync_groups_privacy_settings(Array(diff[:change_privacy]))
        sync_domain_memberships(Array(diff[:add_membership]),
                                Array(diff[:remove_membership]))
        sync_members(Array(diff[:add_members]), Array(diff[:remove_members]))
        sync_aliases(Array(diff[:add_aliases]), Array(diff[:remove_aliases]))
        sync_user_aliases(Array(diff[:add_user_aliases]), Array(diff[:remove_user_aliases]))
      end
      # rubocop:enable Metrics/AbcSize

      private

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

      def sync_user_aliases(aliases_to_add, aliases_to_remove)
        aliases_to_add.each do |user, aliases|
          aliases.each do |google_user_alias|
            add_user_alias(user, google_user_alias)
          end
        end

        aliases_to_remove.each do |user, aliases|
          aliases.each do |google_user_alias|
            remove_user_alias(user, google_user_alias)
          end
        end
      end

      def sync_domain_memberships(memberships_to_add, memberships_to_remove)
        memberships_to_add.each do |group, _membership|
          add_domain_membership(group)
        end

        memberships_to_remove.each do |group, _membership|
          remove_domain_membership(group)
        end
      end

      def create_groups(groups_to_create)
        groups_to_create.each do |group, h|
          @google_api.create_group(group.email)

          # Delay to allow group creation on the Google servers before adding
          # members. To be refactored at a later stage. For more info please check:
          # https://developers.google.com/admin-sdk/directory/v1/guides/manage-groups#create_group
          sleep 5

          add_members(group, h[:add_members]) if h.key?(:add_members)
          add_aliases(group, h[:add_aliases]) if h.key?(:add_aliases)
          add_domain_membership(group) if h.key?(:add_membership)
        end
      end

      def sync_groups_privacy_settings(groups_to_sync)
        groups_to_sync.each do |group, privacy|
          @google_api.change_group_privacy_setting(group, privacy.to_google_params)
        end
      end

      def sync_groups_archive_settings(groups_to_sync)
        groups_to_sync.each do |group, is_archived|
          @google_api.change_group_archive_setting(group, is_archived)
        end
      end

      def remove_alias(group, google_alias)
        @google_api.remove_alias(group.email, Helpers::User.username_to_email(google_alias))
      end

      def remove_user_alias(user, google_alias)
        google_email_alias = "#{google_alias}@#{AppConfig.google.main_domain}"
        @google_api.remove_user_alias(user.emails.first, google_email_alias)
      end

      def remove_member(group, member)
        @google_api.remove_member(group.email, member)
      end

      def remove_domain_membership(group)
        @google_api.unset_domain_membership(group.email)
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

      def add_user_alias(user, google_alias)
        google_email_alias = "#{google_alias}@#{AppConfig.google.main_domain}"
        @google_api.add_user_alias(user.emails.first, google_email_alias)
      end

      def add_domain_membership(group)
        @google_api.set_domain_membership(group.email)
      end
    end
  end
end
