module HockeyAppIntegration
  module Actions
    class Diff
      attr_reader :expected_apps, :api_apps, :diff_hash

      def initialize(expected_apps, api_apps)
        @expected_apps = expected_apps
        @api_apps = api_apps
        @diff_hash = empty_hash
      end

      def now!
        find_missing_api_apps
        find_missing_dg_apps
        generate_diff
      end

      private

      def empty_hash
        {
          add_users: {},
          remove_users: {},
          add_teams: {},
          remove_teams: {},
          missing_api_apps: [],
          missing_dg_apps: [],
          errors: [],
        }
      end

      def find_missing_api_apps
        api_apps_array = api_apps.map(&:name)
        dataguru_apps_array = expected_apps.map(&:name)
        diff_hash[:missing_api_apps] = dataguru_apps_array - api_apps_array
      end

      def find_missing_dg_apps
        api_apps_array = api_apps.map(&:name)
        dataguru_apps_array = expected_apps.map(&:name)
        missing_apps_names = api_apps_array - dataguru_apps_array
        diff_hash[:missing_dg_apps] = api_apps.select { |a| missing_apps_names.include?(a.name) }
      end

      def generate_diff
        expected_apps.each do |expected_app|
          api_app = api_apps.detect { |a| a.public_identifier == expected_app.public_identifier }
          AppDiff.new(expected_app, api_app, diff_hash).diff! unless api_app.nil?
        end
        diff_hash
      end
    end
  end
end
