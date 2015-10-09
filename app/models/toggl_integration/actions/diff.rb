module TogglIntegration
  module Actions
    class Diff
      attr_reader :local_teams, :current_teams, :errors

      def initialize(local_teams, current_teams)
        @local_teams = local_teams
        @current_teams = current_teams
        @errors = []
      end

      def call
        reset_diff_hash
        diff_teams
        diff_hash
      end

      def diff_hash
        @diff_hash ||= {
          create_teams: [],
          add_members: {},
          remove_members: {},
          missing_teams: [],
        }
      end

      private

      def diff_teams
        local_teams.each do |local_team|
          server_team = current_teams.find { |st| st.name.downcase == local_team.name.downcase }
          if server_team
            diff_teams_members(local_team, server_team)
            current_teams.delete(server_team)
          else
            diff_hash[:create_teams] << local_team
          end
        end
        diff_hash[:missing_teams].concat current_teams if current_teams.any?
      end

      def diff_teams_members(local_team, server_team)
        return unless local_team.name == server_team.name
        local_team.members.each do |local_member|
          server_member = server_team.members.find { |sm| sm.downcase == local_member.downcase }
          if server_member
            server_team.members.delete(server_member)
          else
            diff_hash_array(:add_members, server_team) << local_member
          end
        end
        unless server_team.members.empty?
          diff_hash_array(:remove_members, server_team).concat server_team.members
        end
      end

      def diff_hash_array(group, team)
        diff_hash[group][team] ||= []
      end

      def reset_diff_hash
        @diff_hash = nil
      end
    end
  end
end
