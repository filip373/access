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
          members.each do |_key, member|
            @rollbar_api.invite_member_to_team(member.emails.first, team.id)
          end
        end

        members_to_remove.each do |team, members|
          members.each do |_key, member|
            if member.status == 'pending'
              @rollbar_api.cancel_invitation(member.id)
            else
              @rollbar_api.remove_member_from_team(member.id, team.id)
            end
          end
        end
      end

      def sync_projects(projects_to_add, projects_to_remove)
        projects_to_add.each do |team, projects|
          projects.each do |_project_name, project|
            @rollbar_api.add_project_to_team(project.id, team.id)
          end
        end

        projects_to_remove.each do |team, projects|
          projects.each do |_project_name, project|
            @rollbar_api.remove_project_from_team(project.id, team.id)
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
        members.each do |_key, member|
          @rollbar_api.invite_member_to_team(member.emails.first, team.id)
        end
      end

      def new_team_add_projects(projects, team)
        projects.each do |_project_name, project|
          @rollbar_api.add_project_to_team(project.id, team.id)
        end
      end
    end
  end
end
