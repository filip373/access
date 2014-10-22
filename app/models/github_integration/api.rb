module GithubIntegration
  class Api
    attr_accessor :token, :company_name, :dry_run, :log

    def initialize(token, company_name)
      self.token = token
      self.company_name = company_name
      self.dry_run = false
      self.log = []
    end

    alias_method :dry_run?, :dry_run

    def client
      @client ||= Github.new(oauth_token: token, org: company_name, auto_pagination: true)
    end

    def create_team(team_name, permission)
      @log << "[api] create team #{team_name}"
      if dry_run?
        team = Hashie::Mash.new members: [], name: team_name, permission: permission, fake: true
      else
        client.organizations.teams.create(company_name, { name: team_name, permission: permission } )
      end
    end

    def remove_team(team)
      @log << "[api] remove team #{team.name}"
      client.organizations.teams.delete(team.id) unless dry_run?
    end

    def sync_members(team, members_names)
      current_members = team.respond_to?(:fake) ? [] : list_team_members(team['id'])

      add_members = members_names - current_members
      remove_members = current_members - members_names

      add_members.each { |m|
        already_invited = begin
          !!client.get_request("/teams/#{team.id}/memberships/#{m}")
        rescue Github::Error::NotFound
          false
        end
        unless already_invited
          @log << "[api] add member #{m} to team #{team.name}"
          client.put_request("/teams/#{team.id}/memberships/#{m}") unless dry_run?
        end
      }
      remove_members.each { |m|
        @log << "[api] remove member #{m} from team #{team.name}"
        client.delete_request("/teams/#{team.id}/memberships/#{m}") unless dry_run?
      }
    end

    def sync_repos(team, repos_names)
      current_repos = team.respond_to?(:fake) ? [] : list_team_repos(team['id'])

      add_repos = repos_names - current_repos
      remove_repos = current_repos - repos_names

      add_repos.each do |repo_name|
        find_or_create_repo(repo_name)
        @log << "[api] add repo #{repo_name} to team #{team.name}"
        client.orgs.teams.add_repo(team.id, company_name, repo_name) unless dry_run?
      end
      remove_repos.each { |repo_name|
        @log << "[api] remove repo #{repo_name} from team #{team.name}"
        client.orgs.teams.remove_repo(team.id, company_name, repo_name) unless dry_run?
      }
    end

    def get_team(team_name)
      teams.find { |t| t.name == team_name }
    end

    def list_team_members(team_id)
      r = client.organizations.teams.list_members(team_id)
      r.map { |e| e['login'] }
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

    def sync_team_permission(team, expected_permission)
      return if team.permission == expected_permission
      @log << "[api] change permission #{team.name} - #{expected_permission}"
      client.organizations.teams.edit(team.id, { name: team.name, permission: expected_permission }) unless dry_run?
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
      @log << "[api] create repo #{repo_name}"
      client.repos.create(org: company_name, name: repo_name, private: true) unless dry_run?
    end
  end

end
