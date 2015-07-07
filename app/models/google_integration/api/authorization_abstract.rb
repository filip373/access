class GoogleIntegration::Api
  class AuthorizationAbstract
    pattr_initialize [:credentials]

    def authorize!
      raise NotImplementedError, 'implement authorize! in a subclass.
        It must return an instance of Signet::OAuth2::Client'
    end

    def access_token
      raise NotImplementedError, 'implement access_token! in a subclass.'
    end
  end
end
