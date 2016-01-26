module HockeyAppIntegration
  class MainController < ApplicationController
    expose(:expected_apps) do
      HockeyAppIntegration::App.all_from_dataguru(data_guru.hockeyapp_apps.all)
    end
    expose(:hockeyapp_apps) do
      HockeyAppIntegration::App.all_from_api(HockeyAppIntegration::Api.new)
    end

    def calculate_diff
      redirect_to hockeyapp_show_diff_path
    end

    def show_diff
      render locals: { facade: ::HockeyAppFacade.new(calculated_diff, data_guru) }
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
