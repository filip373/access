module JiraIntegration
  module Actions
    class Log
      method_object :diff

      def call
        @messages = []
        generate
        messages
      end

      private

      def generate
        members_to_add(diff[:add_members])
        members_to_remove(diff[:remove_members])
      end

      def members_to_add(projects)
        MemberIterator.new(projects).each do |key, role, member|
          log(:add_member, key: key, role: role, member: member)
        end
      end

      def members_to_remove(projects)
        MemberIterator.new(projects).each do |key, role, member|
          log(:remove_member, key: key, role: role, member: member)
        end
      end

      def log(action, options)
        messages << ['[api]', I18n.t(action, options.merge(scope: :jira))].join(' ')
      end

      attr_reader :messages
    end
  end
end
