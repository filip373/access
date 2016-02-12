module GithubWorkers
  class Base < BaseWorker
    def self.diff_key
      'github_performing_diff'
    end

    private

    def expected_teams
      @expected_teams ||= GithubIntegration::Team.all(data_guru.github_teams)
    end

    def api
      @api ||= GithubIntegration::Api.new(@session_token, AppConfig.company)
    end

    def api_teams
      @api_teams ||= api.list_teams
    end
  end
end
