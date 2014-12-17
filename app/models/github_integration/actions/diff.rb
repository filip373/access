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
          change_permissions: {}
        }
      end

      def now!
        generate_diff
        @diff_hash
      end

      private

      def generate_diff
        @expected_teams.each do |expected_team|
          members = map_users_to_members(expected_team.members)
          gh_team = find_or_create_gh_team(expected_team)

          members_diff(gh_team, members)
          repos_diff(gh_team, expected_team.repos)
          team_permissions_diff(gh_team, expected_team.permission)
        end
      end

      def team_permissions_diff(team, expected_permission)
        if team.respond_to?(:id)
          return if team.permission == expected_permission
          @diff_hash[:change_permissions][team] = expected_permission
        else
          @diff_hash[:create_teams][team][:add_permissions] = expected_permission unless expected_permission.empty?
        end
      end

      def members_diff(team, members_names)
        if team.respond_to?(:id)
          current_members = team.respond_to?(:fake) ? [] : list_team_members(team['id'])
          add = members_names - current_members
          remove = current_members - members_names
          @diff_hash[:add_members][team] = add if add.size > 0
          @diff_hash[:remove_members][team] = remove if remove.size > 0
        else
          @diff_hash[:create_teams][team][:add_members] = members_names unless members_names.empty?
        end
      end

      def repos_diff(team, repos_names)
        if team.respond_to?(:id)
          current_repos = team.respond_to?(:fake) ? [] : list_team_repos(team['id'])
          add = repos_names - current_repos
          remove = current_repos - repos_names
          @diff_hash[:add_repos][team] = add if add.size > 0
          @diff_hash[:remove_repos][team] = remove if remove.size > 0
        else
          @diff_hash[:create_teams][team][:add_repos] = repos_names unless repos_names.empty?
        end
      end

      def list_team_members(team_id)
        r = @gh_api.list_team_members(team_id)
        r.map { |e| e['login'] }
      end

      def map_users_to_members(members)
        members.map do |m|
          user = User.find(m)
          raise "Unknown user #{m}" if user.nil?
          user.github
        end
      end

      def list_team_repos(team_id)
        repos = @gh_api.list_team_repos(team_id)
        repos = repos.group_by { |e| e['name'] }.map do |name, repos|
          # strange corner case - api is returning something different than what's on the github page
          # the api returns both original repos and it's forks - but we want to manage only the main repo
          # hence we will drop the forks if there are any
          repos.reject! { |e| e['fork'] } if repos.size > 1
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

    end
  end
end
