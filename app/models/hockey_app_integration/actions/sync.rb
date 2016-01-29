module HockeyAppIntegration
  module Actions
    class Sync
      attr_reader :hockeyapp_api, :diff
      def initialize(hockeyapp_api, diff)
        @hockeyapp_api = hockeyapp_api
        @diff = diff
      end

      def now!
        sync_add_teams
        sync_remove_teams
        sync_add_users
        sync_remove_uers
      end

      private

      def all_teams
        @all_teams ||= hockeyapp_api.list_teams['teams']
      end

      def find_team_id(team_name)
        all_teams.each do |team|
          return team['id'] if team['name'] == team_name
        end
      end

      def all_app_users(app)
        @all_app_users ||= hockeyapp_api.list_app_users(app.public_identifier)
      end

      def find_user_id(app, user_email)
        all_app_users(app).each do |user|
          return user['id'] if user['email'] == user_email
        end
      end

      def sync_add_teams
        diff[:add_teams].each do |app, teams|
          teams.each do |team|
            team_id = find_team_id(team)
            hockeyapp_api.add_team_to_app(app.public_identifier, team_id)
          end
        end
      end

      def sync_remove_teams
        diff[:remove_teams].each do |app, teams|
          teams.each do |team|
            team_id = find_team_id(team)
            hockeyapp_api.remove_team_from_app(app.public_identifier, team_id)
          end
        end
      end

      def sync_add_users
        diff[:add_users].each do |app, users|
          users.each do |role, user|
            role_id = role_to_id(role)
            hockeyapp_api.invite_user_to_app(app.public_identifier, user.emails.first, role_id)
          end
        end
      end

      def sync_remove_users
        diff[:remove_users].each do |app, users|
          users.each do |_role, user|
            user_id = find_user_id(user.emails.first)
            hockeyapp_api.remove_user_from_app(app.public_identifier, user_id)
          end
        end
      end
    end
  end
end
