module JiraIntegration
  module Diffs
    class Memberships
      method_object :jira_api, :dataguru_api

      def call
        actual.easy_diff(expected)
      end

      private

      def actual
        Factories::JiraProjects.call(jira_api, dataguru_projects)
      end

      def expected
        dataguru_projects.each_with_object({}) do |project, hash|
          hash[project.key] = project.attributes.slice(*Constants::DATAGURU_ROLES)
        end
      end

      def dataguru_projects
        @projects ||= dataguru_api.jira_projects.select do |project|
          jira_project_keys.include?(project.key)
        end
      end

      def jira_project_keys
        @jira_project_keys ||= jira_api.projects.map(&:key)
      end
    end
  end
end
