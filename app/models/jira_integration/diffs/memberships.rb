module JiraIntegration
  module Diffs
    class Memberships
      JIRA_ROLES = ['Developers', 'PM Team', 'QA Team', 'Client Dev', 'Clients'].freeze
      DATAGURU_ROLES = [:developers, :pms, :qas, :client_developers, :clients].freeze
      ROLES_MAPPING = Hash[JIRA_ROLES.zip(DATAGURU_ROLES)].freeze
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
          hash[project.key] = project.attributes.slice(*DATAGURU_ROLES)
        end
      end

      def dataguru_projects
        @projects ||= dataguru_api.jira_projects
      end

      def project_roles(project)
        roles_for(project.key).each_with_object({}) do |(role, link), roles|
          roles[ROLES_MAPPING[role]] = role_members(link).map { |member| member['name'] }
        end
      end

      def roles_for(project_key)
        jira_api.roles_for(project_key).slice(*JIRA_ROLES)
      end

      def role_members(link)
        jira_api
          .role_members(link.gsub(AppConfig.jira.site, ''))
          .fetch('actors') { [] }
          .select { |member| member['type'] == 'atlassian-user-role-actor' }
      end
    end
  end
end
