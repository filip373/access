module GithubIntegration
  class Api
    attr_accessor :token, :company_name

    def initialize(token, company_name)
      self.token = token
      self.company_name = company_name
    end

    def namespace
      @namespace ||= :github
    end

    def client
      @client ||= Github.new(oauth_token: token, org: company_name, auto_pagination: true)
    end

    def create_team(team_name, permission)
      response = client.organizations.teams.create(
        company_name,
        name: team_name,
        permission: permission,
      )
      yield(response) if block_given?
      response
    end

    def remove_team(team)
      client.organizations.teams.delete(team.id)
    end

    def add_member(member, team)
      client.put_request("/teams/#{team.id}/memberships/#{member}")
    rescue Github::Error::NotFound
      nil
    end

    def remove_member(member, team)
      client.delete_request("/teams/#{team.id}/memberships/#{member}")
    end

    def add_repo(repo, team)
      find_or_create_repo(repo)
      client.orgs.teams.add_repo(team.id, company_name, repo)
    end

    def remove_repo(repo_name, team)
      list_team_repos(team.id).select { |e| e.name == repo_name }.each do |repo|
        client.delete_request("/teams/#{team.id}/repos/#{repo.owner.login}/#{repo_name}")
      end
    end

    def add_permission(permission, team)
      client.organizations.teams.edit(team.id, name: team.name, permission: permission)
    end

    def list_org_members(org_name)
      client.organizations.members.all(org_name)
    end

    def list_org_members_without_2fa(org_name)
      client.organizations.members.all(org_name, filter: '2fa_disabled').to_a
    end

    def get_user(login)
      client.users.get(user: login).body
    end

    def list_teams
      @teams ||= begin
        teams =  client.organizations.teams.list(org: company_name)
        teams.flatten.reject { |e| e.name == 'Owners' }
      end
    end

    def list_team_members(team_id)
      client.organizations.teams.list_members(team_id)
    end

    def list_team_repos(team_id)
      client.organizations.teams.list_repos(team_id)
    end

    def team_member_pending?(team_id, user_name)
      find_team_membership(team_id, user_name)['state'] == 'pending'
    rescue Github::Error::NotFound
      false
    end

    def find_organization_id(team_id)
      @organization_id ||= client.get_request("/teams/#{team_id}").organization[:id]
    rescue Github::Error::NotFound
      false
    end

    private

    def find_team_membership(team_id, user_name)
      client.get_request("/teams/#{team_id}/memberships/#{user_name}")
    end

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
