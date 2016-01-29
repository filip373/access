module JiraIntegration
  module Actions
    class Sync
      method_object :diff, :jira_api, :dataguru_api
      attr_accessor :errors
      attr_reader :users_repo
      MEMBER_NOT_FOUND = ->(member) { "Member #{member} not found in JIRA" }

      def call
        @errors = []
        @users_repo = UserRepository.new

        add_members(diff[:add_members])
        remove_members(diff[:remove_members])
        self
      end

      private

      def add_members(projects)
        each_member(projects) do |project_role_ids, key, name, member|
          response = jira_api.add_member_to_role(key, project_role_ids[name], member)
          handle_error(response, MEMBER_NOT_FOUND[member])
        end
      end

      def remove_members(projects)
        each_member(projects) do |project_role_ids, key, name, member|
          response = jira_api.remove_member_from_role(key, project_role_ids[name], member)
          handle_error(response, MEMBER_NOT_FOUND[member.id])
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
        projects.each do |(key, roles)|
          project_role_ids = role_ids(key)
          roles.each do |name, members|
            members.each { |member| yield project_role_ids, key, name, user_repo.find(member) }
          end
        end
      end
    end
  end
end
