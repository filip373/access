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
        sync_remove_users
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
        hockeyapp_api.list_app_users(app.public_identifier)['app_users']
      end

      def find_user_id(app, user_email)
        all_app_users(app).each do |user|
          return user['id'] if user['email'] == user_email
        end
      end

      def sync_add_teams
        each_team(diff[:add_teams]) do |team_id, app_id|
          hockeyapp_api.add_team_to_app(app_id, team_id)
        end
      end

      def sync_remove_teams
        each_team(diff[:remove_teams]) do |_app_id, team_id|
          hockeyapp_api.remove_team_from_app(app.public_identifier, team_id)
        end
      end

      def sync_add_users
        each_user(diff[:add_users]) do |role_id, user_email, _user_id, app_id|
          hockeyapp_api.invite_user_to_app(app_id, user_email, role_id)
        end
      end

      def sync_remove_users
        each_user(diff[:remove_users]) do |_role_id, _user_email, user_id, app_id|
          hockeyapp_api.remove_user_from_app(app_id, user_id)
        end
      end

      def each_team(app_teams_hash)
        app_teams_hash.each do |app, teams|
          teams.each do |team|
            yield find_team_id(team), app.public_identifier
          end
        end
      end

      def each_user(app_users_hash)
        app_users_hash.each do |app, users|
          users.each do |role, user|
            role_id = MainHelper.role_to_id(role)
            user_email = user.first.emails.first
            user_id = find_user_id(app, user_email)
            yield role_id, user_email, user_id, app.public_identifier
          end
        end
      end
    end
  end
end
