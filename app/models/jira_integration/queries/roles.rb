module JiraIntegration
  module Queries
    class Roles
      def self.call(jira_api, project_key, force: false)
        Rails.cache.fetch("jira-project-#{project_key}-roles", force: force) do
          jira_api.roles_for(project_key)
        end
      end
    end
  end
end
