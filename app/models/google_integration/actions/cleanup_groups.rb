module GoogleIntegration
  module Actions
    class CleanupGroups
      attr_accessor :expected_groups, :api

      def initialize(expected_groups, api)
        self.expected_groups = expected_groups
        self.api = api
      end

      def now!
        remove_stranded_groups
      end

      def stranded_groups
        expected_names = expected_groups.map(&:name)
        api.list_groups.reject { |e| Helpers::User.email_to_username(e['email']).in?(expected_names) }
      end

      private

      def remove_stranded_groups
        stranded_groups.each do |group|
          api.remove_group(group)
        end
      end
    end
  end
end
