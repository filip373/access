module GithubIntegration
  class Api
    attr_accessor :token, :company_name

    def initialize(token, company_name)
      self.token = token
      self.company_name = company_name
    end

    def client
      @client ||= Github.new(oauth_token: token, org: company_name, auto_pagination: true)
    end

    def create_team(team_name, permission)
      response = client.organizations.teams.create(company_name, { name: team_name, permission: permission } )
      yield(response) if block_given?
    end

    def remove_team(team)
      client.organizations.teams.delete(team.id)
    end

    def add_member(member, team)
      already_invited = begin
        !!client.get_request("/teams/#{team.id}/memberships/#{member}")
      rescue Github::Error::NotFound
        false
      end
      unless already_invited
        client.put_request("/teams/#{team.id}/memberships/#{member}")
      end
    end

    def remove_member(member, team)
      client.delete_request("/teams/#{team.id}/memberships/#{member}")
    end

    def add_repo(repo, team)
      find_or_create_repo(repo)
      client.orgs.teams.add_repo(team.id, company_name, repo)
    end

    def remove_repo(repo, team)
      client.orgs.teams.remove_repo(team.id, company_name, repo)
    end

    def new_permission(permissions, team)
      client.organizations.teams.edit(team.id, { name: team.name, permission: permissions })
    end

    def list_org_members(org_name)
      client.organizations.members.all(org_name)
    end

    def get_user(login)
      client.users.get(user: login).body
    end

    def teams
      @teams ||= begin
        teams =  client.organizations.teams.list(org: company_name)
        teams.flatten.reject { |e| e.name == 'Owners' }
      end
    end

    private

    def find_or_create_repo(repo_name)
      get_repo(repo_name) || create_repo(repo_name)
    end

    def get_repo(repo_name)
      client.repos.get(company_name, repo_name)
    rescue Github::Error::NotFound
      nil
    end

    def create_repo(repo_name)
      client.repos.create(org: company_name, name: repo_name, private: true)
    end

  end
end
