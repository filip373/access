module HockeyAppIntegration
  class MainController < ApplicationController
    expose(:validations_errors) { data_guru.errors }
    expose(:missing_apps_in_api) { calculated_diff[:missing_api_apps] }
    expose(:missing_apps_in_dg) { calculated_diff[:missing_dg_apps] }
    expose(:hockeyapp_log) { HockeyAppIntegration::Actions::Log.new(calculated_diff).now! }
    expose(:expected_apps) do
      HockeyAppIntegration::App.all_from_dataguru(data_guru.hockeyapp_apps.all)
    end
    expose(:hockeyapp_apps) do
      HockeyAppIntegration::App.all_from_api(hockeyapp_api)
    end
    expose(:hockeyapp_api) { HockeyAppIntegration::Api.new }
    expose(:user_repo) { UserRepository.new(data_guru.members.all) }

    def calculate_diff
      redirect_to hockeyapp_show_diff_path
    end

    def show_diff
    end

    def refresh_cache
      reset_cache
      redirect_to hockeyapp_calculate_diff_path
    end

    def sync
    end

    private

    def reset_cache
      Rails.cache.delete('hockeyapp_calculated_diff')
    end

    def calculated_diff
      Rails.cache.fetch('hockeyapp_calculated_diff') do
        Actions::Diff.new(expected_apps, hockeyapp_apps).now!
      end
    end
  end
end
