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
        sync_projects(diff[:add_projects], diff[:remove_projects])
        sync_members(diff[:add_members], diff[:remove_members])
      end

      def sync_members(teams_with_members_to_add, teams_with_members_to_remove)
        invite_members(teams_with_members_to_add)
        remove_members(teams_with_members_to_remove)
      end

      def sync_projects(projects_to_add, projects_to_remove)
        sync_projects_to_add(projects_to_add)
        sync_projects_to_remove(projects_to_remove)
      end

      def sync_projects_to_add(projects_to_add)
        projects_to_add.each do |team, projects|
          projects.each do |_project_name, project|
            project = @rollbar_api.create_project(project.name) if project.id.nil?
            @rollbar_api.add_project_to_team(project.id, team.id)
          end
        end
      end

      def sync_projects_to_remove(projects_to_remove)
        projects_to_remove.each do |team, projects|
          projects.each do |_project_name, project|
            @rollbar_api.remove_project_from_team(project.id, team.id)
          end
        end
      end

      def create_teams(teams_to_create)
        teams_to_create.each do |team, h|
          @rollbar_api.create_team(team.name).tap do |created_team|
            new_team_add_members(h[:add_members], created_team)
            new_team_add_projects(h[:add_projects], created_team)
          end
        end
      end

      def new_team_add_members(members, team)
        return if members.nil?
        members.each do |_key, member|
          @rollbar_api.invite_member_to_team(member.emails.first, team.id)
        end
      end

      def new_team_add_projects(projects, team)
        return if projects.nil?
        projects.each do |_project_name, project|
          project = @rollbar_api.create_project(project.name) if project.id.nil?
          @rollbar_api.add_project_to_team(project.id, team.id)
        end
      end

      private

      def invite_members(teams_with_members_to_add)
        teams_with_members_to_add.each do |team, members|
          members.values.each do |member|
            @rollbar_api.invite_member_to_team(member.emails.first, team.id)
          end
        end
      end

      def remove_members(teams_with_members_to_remove)
        teams_with_members_to_remove.each do |team, members|
          members.values.each do |member|
            if member.status == 'pending'
              @rollbar_api.cancel_invitation(member.id)
            else
              @rollbar_api.remove_member_from_team(member.id, team.id)
            end
          end
        end
      end
    end
  end
end
