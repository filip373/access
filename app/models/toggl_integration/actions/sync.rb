module TogglIntegration
  module Actions
    class Sync
      pattr_initialize :diffs, :toggl_api

      def call
        add_members
        remove_members
        deactivate_members
        create_teams
        create_tasks
        remove_tasks
      end

      private

      def create_tasks
        diffs[:create_tasks].each do |team, tasks|
          tasks.each { |task| toggl_api.add_task_to_project(task.name, team.id) }
        end
      end

      def remove_tasks
        ids = diffs[:remove_tasks].map(&:id)
        toggl_api.remove_tasks_from_project(ids)
      end

      def add_members
        diffs[:add_members].each do |team, members|
          add_team_members(team, members)
        end
      end

      def remove_members
        diffs[:remove_members].each do |team, members|
          members.each do |member|
            toggl_api.remove_member_from_team(member, team)
          end
        end
      end

      def deactivate_members
        diffs[:deactivate_members].each do |member|
          toggl_api.deactivate_member(member)
        end
      end

      def create_teams
        diffs[:create_teams].each do |team, members|
          new_team = toggl_api.create_team(team)
          new_team = Team.new(
            name: new_team['name'],
            members: new_team['members'],
            projects: [],
            tasks: [new_team['tasks']],
            id: new_team['id'])
          add_team_members(new_team, members)
        end
      end

      def add_team_members(team, members)
        members.each do |member|
          member = invite_member(member) unless member.toggl_id?
          toggl_api.add_member_to_team(member, team)
        end
      end

      def invite_member(member)
        @sent_invitations ||= {}
        return @sent_invitations[member] if @sent_invitations.key?(member)
        invitation_result = toggl_api.invite_member(member)
        invited_member = TogglIntegration::Member.new(
          emails: member.emails, id: member.id, toggl_id: invitation_result['uid'])
        @sent_invitations[member] = invited_member
      end
    end
  end
end
