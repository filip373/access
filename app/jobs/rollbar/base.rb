module RollbarWorkers
  class Base < ActiveJob::Base
    private

    def data_guru
      @data_guru ||= DataGuru::Client.new
    end

    def user_repo
      @user_repo ||= UserRepository.new(data_guru.members.all)
    end

    def dataguru_teams
      @dataguru_teams ||= RollbarIntegration::Team.all_from_dataguru(data_guru.rollbar_teams)
    end

    def rollbar_teams
      @rollbar_teams ||= RollbarIntegration::Team.all_from_api(rollbar_api, user_repo)
    end

    def build_projects_for_teams
      @rollbar_teams = RollbarIntegration::Team.add_projects(rollbar_teams, rollbar_api)
    end

    def rollbar_api
      @rollbar_api ||= RollbarIntegration::Api.new
    end
  end
end
