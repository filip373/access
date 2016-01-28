module JiraIntegration
  class Api
    attr_private_initialize :jira_client

    def user(name)
      jira_client.User.find(name)
    end

    def projects
      jira_client.Project.all
    end

    def roles_for(project_key)
      JSON.parse(jira_client.get("/rest/api/2/project/#{project_key}/role").body)
    rescue ::JIRA::HTTPError
      Rollbar.info("There is no JIRA project with key #{project_key}")
      {}
    end

    def role_members(link)
      JSON.parse(jira_client.get(link).body)
    end
  end
end
