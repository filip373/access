module RollbarIntegration
  module Actions
    class Sync
      def initialize(rollbar_api)
        @rollbar_api = rollbar_api
      end

      def now!(diff)
        sync(diff)
      end

      private

      def sync(diff)
        create_teams(diff[:create_teams])
        sync_members(diff[:add_members], diff[:remove_members])
        sync_projects(diff[:add_projects], diff[:remove_projects])
      end

      def sync_members(members_to_add, members_to_remove)
        members_to_add.each do |team, members|
          members.each do |member|
            @rollbar_api.add_member(member, team)
          end
        end

        members_to_remove.each do |team, members|
          members.each do |member|
            @rollbar_api.remove_member(member, team)
          end
        end
      end

      def sync_projects(projects_to_add, projects_to_remove)
        projects_to_add.each do |team, projects|
          projects.each do |project|
            @rollbar_api.add_project(project, team)
          end
        end

        projects_to_remove.each do |team, projects|
          projects.each do |project|
            @rollbar_api.remove_project(project, team)
          end
        end
      end

      def create_teams(teams_to_create)
        teams_to_create.each do |team, h|
          @rollbar_api.create_team(team.name) do |created_team|
            new_team_add_members(h[:add_members], created_team)
            new_team_add_projects(h[:add_projects], created_team)
          end
        end
      end

      def new_team_add_members(members, team)
        members.each do |member|
          @rollbar_api.add_member(member, team)
        end
      end

      def new_team_add_projects(projects, team)
        projects.each do |project|
          @rollbar_api.add_project(project, team)
        end
      end
    end
  end
end
