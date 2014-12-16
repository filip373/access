module GoogleIntegration
  module Actions
    class Diff < BaseActions::Diff::Base
      include GoogleIntegrationHelper

      attr_accessor :model_name
      create_model_finder_method :group
      create_methods_for_items :members, :aliases

      def initialize(expected_groups, api)
        super
        @model_name = :group
        @diff = {
          create_groups: {},
          add_members: {},
          remove_members: {},
          add_aliases: {},
          remove_aliases: {}
        }
      end

      private

      def generate_diff
        @expected_models.each do |expected_group|
          members = map_members_to_users(expected_group.members) { |m| user_mail(m) }
          google_group = find_or_create_group(expected_group)

          members_diff(google_group, members)
          aliases_diff(google_group, expected_group.aliases)
        end
      end

      def list_group_members(group)
        @api.list_members(group['id']).map{ |m| m['email'] }
      end

      def list_group_aliases(aliaz)
        aliases = get_groups.find { |g| g.name == aliaz['name'] }["aliases"]
        aliases.map { |a| a.values }.flatten
      end
    end
  end
end
