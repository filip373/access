module GithubIntegration
  module Actions
    class SyncTeams

      def initialize(gh_api)
        @gh_api = gh_api
      end

      def now!(diff)
        sync(diff)
      end

      private

      def sync(diff)
        create_teams(diff[:create_teams])
        sync_members(diff[:add_members], diff[:remove_members])
        sync_repos(diff[:add_repos], diff[:remove_repos])
        sync_teams_permissions(diff[:change_permissions])
      end

      def sync_members(members_to_add, members_to_remove)
        members_to_add.each do |team, members|
          members.each do |member|
            @gh_api.add_member(member, team)
          end
        end

        members_to_remove.each do |team, members|
          members.each do |member|
            @gh_api.remove_member(member, team)
          end
        end
      end

      def sync_repos(repos_to_add, repos_to_remove)
        repos_to_add.each do |team, repos|
          repos.each do |repo|
            @gh_api.add_repo(repo, team)
          end
        end

        repos_to_remove.each do |team, repos|
          repos.each do |repo|
            @gh_api.remove_repo(repo, team)
          end
        end
      end

      def sync_teams_permissions(change_permissions)
        change_permissions.each do |team, permissions|
          @gh_api.new_permission(permissions, team)
        end
      end

      def create_teams(teams_to_create)
        teams_to_create.each do |team, h|
          @gh_api.create_team(team.name, h[:add_permissions]) do |created_team|
            new_team_add_members(h[:add_members], created_team)
            new_team_add_repos(h[:add_repos], created_team)
            new_team_add_permissions(h[:add_permissions], created_team)
          end
        end
      end

      def new_team_add_members(members, team)
        members.each do |member|
          @gh_api.add_member(member, team)
        end
      end

      def new_team_add_repos(repos, team)
        repos.each do |repo|
          @gh_api.add_repo(repo, team)
        end
      end

      def new_team_add_permissions(permissions, team)
        @gh_api.new_permission(permissions, team)
      end

    end
  end
end
