class GoogleIntegration::Api
  class MockAccountAuthorization < AuthorizationAbstract
    def authorize!
      self
    end

    def email
      self
    end

    def user_info
      self
    end
  end
end
