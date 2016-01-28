module HockeyAppIntegration
  class App
    attr_reader :name, :public_identifier, :teams, :testers, :members, :developers, :optional_info

    def initialize(parameters)
      parameters.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    class << self
      def all_from_dataguru(dataguru_apps, user_repo)
        dataguru_apps.map do |dg_app|
          params = build_params_from_dg(dg_app, user_repo)
          new(params)
        end
      end

      def all_from_api(hockeyapp_api, user_repo)
        all_apps(hockeyapp_api).map do |api_app|
          params = build_params_from_api(hockeyapp_api, api_app, user_repo)
          new(params)
        end
      end

      private

      def build_users(users, user_repo)
        return [] if users.nil?
        user_repo.find_many(users).map { |_k, v| v }
      end

      def build_params_from_dg(app, user_repo)
        {
          name: app.name,
          public_identifier: app.public_identifier,
          teams: app.teams,
          developers: build_users(app.developers, user_repo),
          members: build_users(app.members, user_repo),
          testers: build_users(app.testers, user_repo),
          optional_info: {},
        }
      end

      def build_params_from_api(api, app, user_repo)
        developers, members, testers = find_app_users(api, app['public_identifier'])
        {
          name: app['title'],
          public_identifier: app['public_identifier'],
          teams: find_app_teams(api, app['public_identifier']),
          members: build_users(members, user_repo),
          testers: build_users(testers, user_repo),
          developers: build_users(developers, user_repo),
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
          assign_role(roles_hash, u)
        end.compact
        [users_with_roles[:developers], users_with_roles[:members], users_with_roles[:testers]]
      end

      def assign_role(hash, user)
        role = MainHelper.id_to_role(user['role'])
        unless role == :owners
          hash[role] ||= []
          hash[role] << user['email'].split('@').first
        end
      end

      def find_app_teams(hockeyapp_api, app_id)
        Array(hockeyapp_api.list_app_teams(app_id)['teams']).map { |t| t['name'] }
      end
    end
  end
end
