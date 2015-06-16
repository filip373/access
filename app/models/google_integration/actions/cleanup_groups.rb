module GoogleIntegration
  module Actions
    class CleanupGroups
      attr_accessor :expected_groups, :api, :api_groups

      def initialize(expected_groups, api, api_groups)
        self.expected_groups = expected_groups
        self.api = api
        self.api_groups = api_groups
      end

      def now!
        remove_stranded_groups
      end

      def stranded_groups
        expected_names = expected_groups.map(&:name)
        self.api_groups.reject do |e|
          Helpers::User.email_to_username(e['email']).in?(expected_names)
        end
      end

      private

      def remove_stranded_groups
        stranded_groups.each do |group|
          api.remove_group(group['email'])
        end
      end
    end
  end
end
