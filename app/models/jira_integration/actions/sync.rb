module JiraIntegration
  module Actions
    class Sync
      method_object :diff, :jira_api
      attr_accessor :errors
      attr_reader :users_repo
      MEMBER_NOT_FOUND = ->(member) { "Member #{member.id} not found in JIRA" }

      def call
        @errors = []
        @users_repo = UserRepository.new

        add_members(diff[:add_members])
        remove_members(diff[:remove_members])
        self
      end

      private

      def add_members(projects)
        each_member(projects) do |key, role, member|
          jira_api.add_member(key, role_ids(key)[role], member.id)
        end
      end

      def remove_members(projects)
        each_member(projects) do |key, role, member|
          jira_api.remove_member(key, role_ids(key)[role], member.id)
        end
      end

      def role_ids(key)
        Queries::Roles.call(jira_api, key).each_with_object({}) do |(role, link), hash|
          hash[Constants::ROLES_MAPPING[role]] = link.split('/').last.to_i
        end
      end

      def handle_error(response, error_message)
        errors << error_message if response == :error
      end

      def each_member(projects)
        MemberIterator.new(projects).each do |key, role, member|
          member = users_repo.find(member)
          response = yield key, role, member
          handle_error(response, MEMBER_NOT_FOUND[member])
        end
      end
    end
  end
end
