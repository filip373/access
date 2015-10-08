module TogglIntegration
  module Actions
    class Diff
      attr_reader :local_teams, :errors

      def initialize(local_teams, toggl_api)
        @local_teams = local_teams
        @toggl_api = toggl_api
        @errors = []
      end

      def call
        reset_diff_hash
        diff_teams
        diff_hash
      end

      def diff_hash
        @diff_hash ||= {
          create_teams: {},
          add_members: {},
          remove_members: {},
        }
      end

      private

      # This method is time expensive (calls remote API).
      def server_teams
        @server_teams ||= @toggl_api.list_teams.map do |team|
          Team.from_api_request(@toggl_api, team)
        end
      end

      def diff_teams
        local_teams.each do |local_team|
          server_team = server_teams.find { |st| st.name.downcase == local_team.name.downcase }
          if server_team
            diff_teams_members(local_team, server_team)
            server_teams.delete(server_team)
          else
            diff_array(:create_teams, local_team)
          end
        end
      end

      def diff_teams_members(local_team, server_team)
        return unless local_team.name == server_team.name
        local_team.members.each do |local_member|
          server_member = server_team.members.find { |sm| sm.downcase == local_member.downcase }
          if server_member
            server_team.members.delete(server_member)
          else
            diff_array(:add_members, server_team) << local_member
          end
        end
        unless server_team.members.empty?
          diff_array(:remove_members, server_team).concat server_team.members
        end
      end

      def diff_array(group, team_name)
        diff_hash[group][team_name] ||= []
      end

      def reset_diff_hash
        @diff_hash = nil
      end
    end
  end
end
