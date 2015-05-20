module GithubIntegration
  module Actions
    class Diff
      def initialize(expected_teams, gh_api)
        @expected_teams = expected_teams
        @gh_api = gh_api
        @diff_hash = {
          create_teams: {},
          add_members: {},
          remove_members: {},
          add_repos: {},
          remove_repos: {},
          change_permissions: {},
        }
      end

      def now!
        generate_diff
        @diff_hash
      end

      private

      def generate_diff
        @expected_teams.each do |expected_team|
          gh_team = find_or_create_gh_team(expected_team)
          members = map_users_to_members(expected_team.members)
          members_diff(gh_team, members)
          repos_diff(gh_team, expected_team.repos)
          team_permissions_diff(gh_team, expected_team.permission)
        end
      end

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
          add = exclude_pending_members(add, team.id)
          remove = current_members - members_names
          @diff_hash[:add_members][team] = add if add.any?
          @diff_hash[:remove_members][team] = remove if remove.any?
        else
          @diff_hash[:create_teams][team][:add_members] = members_names unless members_names.empty?
        end
      end

      def repos_diff(team, repos_names)
        if team.respond_to?(:id)
          current_repos = team.respond_to?(:fake) ? [] : list_team_repos(team['id'])
          add = repos_names - current_repos
          remove = current_repos - repos_names
          @diff_hash[:add_repos][team] = add if add.any?
          @diff_hash[:remove_repos][team] = remove if remove.any?
        else
          @diff_hash[:create_teams][team][:add_repos] = repos_names unless repos_names.empty?
        end
      end

      def list_team_members(team_id)
        r = @gh_api.list_team_members(team_id)
        r.map { |e| e['login'] }
      end

      def map_users_to_members(members)
        users = User.find_many(members)
        users.values.map(&:github)
      end

      def list_team_repos(team_id)
        repos = @gh_api.list_team_repos(team_id)
        organization_id = Rails.cache.fetch 'organization_id' do
          @gh_api.find_organization_id(team_id)
        end
        repos = repos.group_by { |e| e['name'] }.map do |_name, repos|
          repos.select! { |e| e['owner']['id'] == organization_id } if repos.size > 1
          repos
        end.flatten
        repos.map { |e| e['name'] }.compact
      end

      def get_team(team_name)
        get_teams.find { |t| t.name.downcase == team_name.downcase }
      end

      def get_teams
        @teams ||= @gh_api.list_teams
      end

      def find_or_create_gh_team(expected_team)
        team = get_team(expected_team.name)
        return team unless team.nil?
        @diff_hash[:create_teams][expected_team] = {}
        expected_team
      end

      def exclude_pending_members(members, team_id)
        members.reject do |user_name|
          Rails.cache.fetch "pending_users/#{user_name}" do
            @gh_api.team_member_pending?(team_id, user_name)
          end
        end
      end
    end
  end
end
