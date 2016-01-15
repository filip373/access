module GoogleWorkers
  class Base < BaseWorker
    private

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
