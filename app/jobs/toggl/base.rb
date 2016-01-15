module TogglWorkers
  class Base < BaseWorker
    private

    def current_members_repository
      @current_members_repository ||= TogglIntegration::MemberRepository.build_from_toggl_api(api)
    end

    def current_tasks_repository
      @current_tasks_repository ||= TogglIntegration::TaskRepository.build_from_toggl_api(api)
    end

    def expected_teams
      @expected_teams ||= TogglIntegration::TeamRepository.build_from_data_guru(
        data_guru,
        user_repo,
        current_members_repository).all
    end

    def api_teams
      @api_teams ||= TogglIntegration::TeamRepository.build_from_toggl_api(
        api,
        user_repo).all
    end

    def api
      @api ||= TogglIntegration::Api.new(AppConfig.toggl_token, AppConfig.company)
    end
  end
end
