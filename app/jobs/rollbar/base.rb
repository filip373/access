module RollbarWorkers
  class Base < BaseWorker
    def self.diff_key
      'rollbar_performing_teams'
    end

    private

    def expected_teams
      @expected_teams ||= RollbarIntegration::Team.all_from_dataguru(data_guru.rollbar_teams)
    end

    def fetch_basic_teams
      @api_teams ||= RollbarIntegration::Team.all_from_api(api, user_repo)
    end

    def api_teams
      @api_teams = RollbarIntegration::Team.add_projects(fetch_basic_teams, api)
    end

    def api
      @api ||= RollbarIntegration::Api.new
    end
  end
end
