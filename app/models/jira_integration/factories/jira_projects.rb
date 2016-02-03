module JiraIntegration
  module Factories
    class JiraProjects
      method_object :jira_api, :projects

      def call
        projects.each_with_object({}) do |project, projects|
          projects[project.key] = project_roles(project)
        end
      end

      private

      def project_roles(project)
        roles_for(project.key).each_with_object({}) do |(role, link), roles|
          roles[Constants::ROLES_MAPPING[role]] = role_members(link).map do |member|
            if [:clients, :client_developers].include?(Constants::ROLES_MAPPING[role])
              'external/' + member['name']
            else
              member['name']
            end
          end
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
    end
  end
end
