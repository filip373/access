module JiraIntegration
  class Api
    attr_private_initialize :jira_client

    def namespace
      :jira
    end

    def user(name)
      jira_client.User.find(name)
    end

    def projects
      jira_client.Project.all
    end

    def roles_for(project_key)
      JSON.parse(jira_client.get("/rest/api/2/project/#{project_key}/role").body)
    rescue JIRA::HTTPError
      Rollbar.info("There is no JIRA project with key #{project_key}")
      {}
    end

    def role_members(link)
      JSON.parse(jira_client.get(link).body)
    end

    def add_member(key, role, member)
      jira_client.post(role_link(key, role), { user: [member] }.to_json)
    rescue JIRA::HTTPError
      Rollbar.info("There is no JIRA member with username #{member}")
      :error
    end

    def remove_member(key, role, member)
      jira_client.delete(role_link(key, role) + "?user=#{member}")
    rescue JIRA::HTTPError
      Rollbar.info("There is no JIRA member with username #{member}")
      :error
    end

    private

    def role_link(key, role_id)
      "/rest/api/2/project/#{key}/role/#{role_id}"
    end
  end
end
