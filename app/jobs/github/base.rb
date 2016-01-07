module GithubWorkers
  class Base < ActiveJob::Base
    private

    def data_guru
      @data_guru ||= DataGuru::Client.new
    end

    def expected_teams
      @expected_teams ||= GithubIntegration::Team.all(data_guru.github_teams)
    end

    def user_repo
      @user_repo ||= UserRepository.new(data_guru.users.all)
    end

    def gh_api
      @gh_api ||= GithubIntegration::Api.new(@session_token, AppConfig.company)
    end

    def gh_teams
      @gh_teams ||= gh_api.list_teams
    end
  end
end
