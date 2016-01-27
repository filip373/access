module JiraIntegration
  module Actions
    class Diff
      method_object :jira_api, :dataguru_api

      def call
        generate
      end

      private

      def generate
        removed_members, added_members = Diffs::Memberships.call(jira_api, dataguru_api)
        zombie_projects, missing_projects = Diffs::Projects.call(jira_api, dataguru_api)
        {
          add_members: added_members,
          remove_members: removed_members,
          missing_projects: missing_projects,
          zombie_projects: zombie_projects,
        }
      end
    end
  end
end
