module HockeyAppIntegration
  class MainController < ApplicationController
    expose(:expected_apps) do
      HockeyAppIntegration::App.all_from_dataguru(data_guru.hockeyapp_apps.all, user_repo)
    end
    expose(:hockeyapp_apps) do
      HockeyAppIntegration::App.all_from_api(HockeyAppIntegration::Api.new, user_repo)
    end

    def calculate_diff
      redirect_to hockeyapp_show_diff_path
    end

    def show_diff
      render locals: { facade: ::HockeyAppFacade.new(calculated_diff, data_guru, user_repo) }
    end

    def refresh_cache
      reset_cache
      redirect_to hockeyapp_calculate_diff_path
    end

    def sync
    end

    private

    def user_repo
      @user_repo ||= UserRepository.new(data_guru.members.all)
    end

    def reset_cache
      Rails.cache.delete('hockeyapp_calculated_diff')
      Rails.cache.delete('hockeyapp_repo_errors')
    end

    def calculated_diff
      Rails.cache.fetch('hockeyapp_calculated_diff') do
        Actions::Diff.new(expected_apps, hockeyapp_apps).now!
      end
    end
  end
end
