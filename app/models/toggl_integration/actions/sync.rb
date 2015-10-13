module TogglIntegration
  module Actions
    class Sync
      pattr_initialize :diffs, :toggl_api

      def call
        add_members
        remove_members
        create_teams
      end

      private

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

      def create_teams
        diffs[:create_teams].each do |team, members|
          new_team = toggl_api.create_team(team)
          new_team = Team.new(new_team['name'], [], [new_team['name']], new_team['id'])
          add_team_members(new_team, members)
        end
      end

      def add_team_members(team, members)
        members.each do |member|
          toggl_api.add_member_to_team(member, team)
        end
      end
    end
  end
end
