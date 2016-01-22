module HockeyAppIntegration
  class App
    attr_reader :name, :public_identifier, :teams, :testers, :members, :developers, :optional_info

    def initialize(parameters)
      parameters.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    class << self
      def all_from_dataguru(dataguru_apps)
        dataguru_apps.map do |dg_app|
          params = build_params_from_dg(dg_app)
          new(params)
        end
      end

      def all_from_api(hockeyapp_api)
        all_apps(hockeyapp_api).map do |api_app|
          params = build_params_from_api(hockeyapp_api, api_app)
          new(params)
        end
      end

      private

      def build_params_from_dg(app)
        {
          name: app.name,
          public_identifier: app.public_identifier,
          teams: app.teams,
          developers: app.developers,
          members: app.members,
          testers: app.testers,
          optional_info: {},
        }
      end

      def build_params_from_api(api, app)
        developers, members, testers = find_app_users(api, app['public_identifier'])
        {
          name: app['title'],
          public_identifier: app['public_identifier'],
          teams: find_app_teams(api, app['public_identifier']),
          members: members,
          testers: testers,
          developers: developers,
          optional_info: {
            id: app['id'],
            platform: app['platform'],
            custom_release_type: app['custom_release_type'],
          },
        }
      end

      def all_apps(hockeyapp_api)
        @all_apps ||= hockeyapp_api.list_apps['apps']
      end

      def find_app_users(hockeyapp_api, app_id)
        users = hockeyapp_api.list_app_users(app_id)['app_users']
        return [] if users.nil?
        users_with_roles = users.each_with_object({}) do |u, roles_hash|
          role = find_role(u['role'])
          unless role == :owner
            roles_hash[role] ||= []
            roles_hash[role] << u['email']
          end
        end.compact
        [users_with_roles[:developers], users_with_roles[:members], users_with_roles[:testers]]
      end

      def find_role(role)
        case role
        when 0
          return :owners
        when 1
          return :developers
        when 2
          return :members
        when 3
          return :testers
        end
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
