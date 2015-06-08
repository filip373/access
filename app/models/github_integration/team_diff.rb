module GithubIntegration
  class TeamDiff
    include Celluloid

    def initialize(expected_team, gh_team, gh_api, diff_hash, blk)
      @diff_hash = diff_hash
      @expected_team = expected_team
      @gh_team = gh_team || create_gh_team
      @gh_api = gh_api
      @blk = blk
      @errors = []
    end

    def diff
      members = map_users_to_members
      members_diff(@gh_team, members)
      repos_diff(@gh_team, @expected_team.repos)
      team_permissions_diff(@gh_team, @expected_team.permission)
      @blk.call(@diff_hash, @errors)
    end

    private

    def team_permissions_diff(team, expected_permission)
      if team.respond_to?(:id)
        return if team.permission == expected_permission
        @diff_hash[:change_permissions][team] = expected_permission
      elsif !expected_permission.blank?
        @diff_hash[:create_teams][team][:add_permissions] = expected_permission
      end
    end

    def members_diff(team, members_names)
      if team.respond_to?(:id)
        current_members = team.respond_to?(:fake) ? [] : list_team_members(team['id'])
        add = members_names - current_members
        @diff_hash[:add_members][team] = exclude_pending_members(add, team.id)
        @diff_hash[:remove_members][team] = current_members - members_names
      elsif !members_names.empty?
        @diff_hash[:create_teams][team][:add_members] = members_names
      end
    end

    def repos_diff(team, repos_names)
      if team.respond_to?(:id)
        current_repos = team.respond_to?(:fake) ? [] : list_team_repos(team['id'])
        @diff_hash[:add_repos][team] = repos_names - current_repos
        @diff_hash[:remove_repos][team] = current_repos - repos_names
      else
        @diff_hash[:create_teams][team][:add_repos] = repos_names unless repos_names.empty?
      end
    end

    def list_team_members(team_id)
      r = @gh_api.list_team_members(team_id)
      r.map { |e| e['login'] }
    end

    def map_users_to_members
      users = User.find_many(@expected_team.members)
      @errors.push(*User.shift_errors) if User.errors.present?
      users.values.map(&:github)
    end

    def list_team_repos(team_id)
      repos = @gh_api.list_team_repos(team_id)
      organization_id = Rails.cache.fetch 'organization_id' do
        @gh_api.find_organization_id(team_id)
      end
      repos.select { |e| e['owner']['id'] == organization_id }.map { |e| e['name'] }
    end

    def exclude_pending_members(members, team_id)
      members.reject do |user_name|
        Rails.cache.fetch "pending_users/#{user_name}" do
          @gh_api.team_member_pending?(team_id, user_name)
        end
      end
    end

    def create_gh_team
      @diff_hash[:create_teams][@expected_team] = {}
      @expected_team
    end
  end
end
