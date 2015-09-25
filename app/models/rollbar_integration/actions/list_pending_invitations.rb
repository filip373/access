module RollbarIntegration
  module Actions
    class ListPendingInvitations
      attr_reader :rollbar_api

      def initialize(rollbar_api)
        @rollbar_api = rollbar_api
        @pending_invitations = []
      end

      def now!
        rollbar_api.list_teams.each do |team|
          rollbar_api.list_team_pending_members(team.id).each do |invitation|
            @pending_invitations.push(
              team_name: team.name,
              member_email: invitation.email)
          end
        end
        @pending_invitations
      end
    end
  end
end
