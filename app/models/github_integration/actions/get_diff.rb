module Diff
  class Github < Base
    attr_accessor :model_name
    create_model_finder_method :team
    create_methods_for_items :members, :repos


    def initialize(expected_teams, api)
      super
      @model_name = :team
      @diff = {
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
      @diff
    end

    private

    def generate_diff
      @expected_models.each do |expected_team|
        members = map_members_to_users(expected_team.members) { |m| m.github }
        gh_team = find_or_create_team(expected_team)

        members_diff(gh_team, members)
        repos_diff(gh_team, expected_team.repos)
        team_permissions_diff(gh_team, expected_team.permission)
      end
    end

    def team_permissions_diff(team, expected_permission)
      if team.respond_to?(:id)
        return if team.permission == expected_permission
        @diff[:change_permissions][team] = expected_permission
      else
        @diff[:create_teams][team][:add_permissions] = expected_permission unless expected_permission.empty?
      end
    end

    def list_team_members(team)
      @api.list_team_members(team['id']).map { |e| e['login'] }
    end

    def list_team_repos(team)
      repos = @api.list_team_repos(team['id'])
      repos = repos.group_by { |e| e['name'] }.map do |name, repos|
        # strange corner case - api is returning something different than what's on the github page
        # the api returns both original repos and it's forks - but we want to manage only the main repo
        # hence we will drop the forks if there are any
        repos.reject! { |e| e['fork'] } if repos.size > 1
        repos
      end.flatten
      repos.map { |e| e['name'] }.compact
    end
  end
end
