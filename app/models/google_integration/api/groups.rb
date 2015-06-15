class GoogleIntegration::Api
  class Groups

    def create(_options)
    end

    private

    def api
      @api ||= client.discovered_api('groupssettings', 'directory_v1')
    end
  end
end
