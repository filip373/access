module GithubIntegration
  class Api
    attr_accessor :token, :company_name, :dry_run

    def initialize(token, company_name)
      self.token = token
      self.company_name = company_name
      self.dry_run = false
    end

    alias_method :dry_run?, :dry_run

    def client
      @client ||= Github.new(oauth_token: token, org: company_name, auto_pagination: true)
    end

    def create_team(team_name, permission)
      if dry_run?
        team = Hashie::Mash.new members: [], name: team_name, permission: permission, fake: true
      else
        response = client.organizations.teams.create(company_name, { name: team_name, permission: permission } )
        yield(response) if block_given?
      end
    end

    def remove_team(team)
      client.organizations.teams.delete(team.id) unless dry_run?
    end

    def add_member(member, team)
      already_invited = begin
        !!client.get_request("/teams/#{team.id}/memberships/#{member}")
      rescue Github::Error::NotFound
        false
      end
      unless already_invited
        client.put_request("/teams/#{team.id}/memberships/#{member}") unless dry_run?
      end
    end

    def remove_member(member, team)
      client.delete_request("/teams/#{team.id}/memberships/#{member}") unless dry_run?
    end

    def add_repo(repo, team)
      find_or_create_repo(repo)
      client.orgs.teams.add_repo(team.id, company_name, repo) unless dry_run?
    end

    def remove_repo(repo, team)
      client.orgs.teams.remove_repo(team.id, company_name, repo) unless dry_run?
    end

    def list_team_repos(team_id)
      repos = client.organizations.teams.list_repos(team_id)
      repos = repos.group_by{|e| e['name'] }.map{|name, repos|
        # strange corner case - api is returning something different than what's on the github page
        # the api returns both original repos and it's forks - but we want to manage only the main repo
        # hence we will drop the forks if there are any
        repos.reject!{|e| e['fork'] } if repos.size > 1
        repos
      }.flatten
      repos.map { |e| e['name']  }.compact
    end

    def new_permission(permissions, team)
      client.organizations.teams.edit(team.id, { name: team.name, permission: permissions }) unless dry_run?
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
      client.repos.create(org: company_name, name: repo_name, private: true) unless dry_run?
    end
  end
end
