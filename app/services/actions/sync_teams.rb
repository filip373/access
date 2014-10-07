module Actions
  class SyncTeams < Struct.new(:expected_teams, :expected_users, :gh_api)

    def now!
      sync_members
    end

    def sync_members
      
      expected_teams.each do |et|
        members = map_users_to_members(et.members)

        gh_team = find_or_create_gh_team(et)
        gh_api.sync_members(gh_team, members)
        gh_api.sync_repos(gh_team, et.repos)
        gh_api.sync_team_permission(gh_team, et.permission)
      end
    end

    private

    def find_or_create_gh_team(expected_team)
      gh_api.get_team(expected_team.name) || gh_api.create_team(expected_team.name)
    end

    def map_users_to_members(members)
      members.map { |m| expected_users[m].github }
    end
  end
end
