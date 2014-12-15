module GoogleIntegration
  module Actions
    class Sync < BaseActions::Sync::Base

      sync_items_methods :members, :aliases
      new_team_items_methods :members, :aliases

      private

      def sync(diff)
        create_groups(diff[:create_groups])
        sync_members(diff[:add_members], diff[:remove_members])
        sync_aliases(diff[:add_aliases], diff[:remove_aliases])
      end

      def create_groups(groups_to_create)
        groups_to_create.each do |group, h|
          @google_api.create_group(group.name) do |created_group|
            new_team_add_members(h[:add_members], created_group)
            new_team_add_aliases(h[:add_aliases], created_group)
          end
        end
      end
    end
  end
end
