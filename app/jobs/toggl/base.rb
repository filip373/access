module TogglWorkers
  class Base < ActiveJob::Base
    private

    def data_guru
      @data_guru ||= DataGuru::Client.new
    end

    def user_repo
      @user_repo ||= UserRepository.new(data_guru.members.all)
    end

    def current_members_repository
      @current_members_repository ||= TogglIntegration::MemberRepository.build_from_toggl_api(
        toggl_api)
    end

    def current_tasks_repository
      @current_tasks_repository ||= TogglIntegration::TaskRepository.build_from_toggl_api(
        toggl_api)
    end

    def expected_teams
      @expected_teams ||= TogglIntegration::TeamRepository.build_from_data_guru(
        data_guru,
        user_repo,
        current_members_repository).all
    end

    def current_teams
      @current_teams ||= TogglIntegration::TeamRepository.build_from_toggl_api(
        toggl_api,
        user_repo).all
    end

    def toggl_api
      @toggl_api ||= TogglIntegration::Api.new(AppConfig.toggl_token, AppConfig.company)
    end
  end
end
