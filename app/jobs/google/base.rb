module GoogleWorkers
  class Base < ActiveJob::Base
    private

    def data_guru
      @data_guru ||= DataGuru::Client.new
    end

    def user_repo
      @user_repo ||= UserRepository.new(data_guru.members.all)
    end

    def expected_groups
      @expected_groups ||= GoogleIntegration::Group.all(data_guru.google_groups)
    end

    def google_api
      @google_api ||= GoogleIntegration::Api.new(
        @session_token,
        authorization: google_authorization,
      )
    end

    def google_authorization
      if Features.on?(:use_service_account)
        GoogleIntegration::Api::ServiceAccountAuthorization
      else
        GoogleIntegration::Api::UserAccountAuthorization
      end
    end
  end
end
