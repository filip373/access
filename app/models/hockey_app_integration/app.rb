module HockeyAppIntegration
  class App
    attr_reader :name, :public_identifier, :teams, :users, :optional_info

    def initialize(name, public_identifier, teams, users, optional_info = {})
      @name = name
      @public_identifier = public_identifier
      @teams = teams
      @users = users
      @optional_info = optional_info
    end

    class << self
      def all_from_dataguru(dataguru_apps)
        dataguru_apps.map do |dg_app|
          new(dg_app.name, dg_app.public_identifier, dg_app.teams, dg_app.users)
        end
      end

      def all_from_api(hockeyapp_api)
        all_apps(hockeyapp_api).map do |api_app|
          teams = find_app_teams(hockeyapp_api, api_app['public_identifier'])
          users = find_app_users(hockeyapp_api, api_app['public_identifier'])
          optional_info = {
            id: api_app['id'],
            platform: api_app['platform'],
            custom_release_type: api_app['custom_release_type'],
          }
          new(api_app['title'], api_app['public_identifier'], teams, users, optional_info)
        end
      end

      private

      def all_apps(hockeyapp_api)
        @all_apps ||= hockeyapp_api.list_apps['apps']
      end

      def find_app_users(hockeyapp_api, app_id)
        users = hockeyapp_api.list_app_users(app_id)['app_users']
        return [] if users.nil?
        users.map do |u|
          u['email'] unless u['email'].include?('office@')
        end.compact
      end

      def find_app_teams(hockeyapp_api, app_id)
        teams = hockeyapp_api.list_app_teams(app_id)['teams']
        return [] if teams.nil?
        teams.map do |t|
          t['name']
        end
      end
    end
  end
end
