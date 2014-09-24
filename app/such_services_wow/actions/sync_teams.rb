module Actions
  class SyncTeams < Struct.new(:expected_teams, :expected_users, :gh_api)

    def now!
      sync_members
    end

    def sync_members
      
      expected_teams.each do |et|
        gh_team = find_or_create_gh_team(et)
        gh_api.sync_members(gh_team, et.members)
        gh_api.sync_repos(gh_team, et.repos)
      end
    end

    private

    def find_or_create_gh_team(expected_team)
      gh_api.get_team(expected_team.name) || gh_api.create_team(expected_team.name)
    end
  end
end
