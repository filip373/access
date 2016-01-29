module JiraIntegration
  module Diffs
    class Memberships
      method_object :jira_api, :dataguru_api

      def call
        actual.easy_diff(expected)
      end

      private

      def actual
        dataguru_projects.each_with_object({}) do |project, projects|
          projects[project.key] = project_roles(project)
        end
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

      def project_roles(project)
        roles_for(project.key).each_with_object({}) do |(role, link), roles|
          roles[Constants::ROLES_MAPPING[role]] = role_members(link).map { |member| member['name'] }
        end
      end

      def roles_for(project_key)
        Queries::Roles.call(jira_api, project_key, force: true).slice(*Constants::JIRA_ROLES)
      end

      def role_members(link)
        jira_api.role_members(link.gsub(AppConfig.jira.site, ''))
          .fetch('actors') { [] }
          .select { |member| member['type'] == 'atlassian-user-role-actor' }
      end

      def jira_project_keys
        jira_api.projects.map(&:key)
      end
    end
  end
end
