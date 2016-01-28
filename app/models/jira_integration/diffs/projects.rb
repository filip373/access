module JiraIntegration
  module Diffs
    class Projects
      method_object :jira_api, :dataguru_api

      def call
        actual.easy_diff(expected)
      end

      private

      def expected
        dataguru_api.jira_projects.each_with_object({}) do |project, hash|
          hash[project.key] = { name: project.name }
        end
      end

      def actual
        jira_api.projects.each_with_object({}) do |project, hash|
          hash[project.key] = { name: project.name }
        end
      end
    end
  end
end
