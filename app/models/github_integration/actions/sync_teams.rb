module Sync
  class Github < Base

    sync_items_methods :members, :repos
    new_team_items_methods :members, :repos

    private

    def sync(diff)
      create_teams(diff[:create_teams])
      sync_members(diff[:add_members], diff[:remove_members])
      sync_repos(diff[:add_repos], diff[:remove_repos])
      sync_teams_permissions(diff[:change_permissions])
    end

    def create_teams(teams_to_create)
      teams_to_create.each do |team, h|
        @api.create_team(team.name, h[:add_permissions]) do |created_team|
          new_team_add_members(h[:add_members], created_team)
          new_team_add_repos(h[:add_repos], created_team)
          new_team_add_permissions(h[:add_permissions], created_team)
        end
      end
    end

    def sync_teams_permissions(change_permissions)
      change_permissions.each do |team, permissions|
        add_permissions(permissions, team)
      end
    end

    def add_permissions(permissions, team)
      @api.add_permission(permissions, team)
    end
  end
end
