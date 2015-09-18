module RollbarIntegration
  class Client
    include HTTParty
    attr_accessor :read_token
    base_uri 'https://api.rollbar.com/'
    default_timeout 1

    def initialize(read_token:)
      self.read_token = read_token
    end

    def get(url, options = {})
      options.merge!(query: { access_token: read_token })
      response = self.class.get(url, options)
      raise ApiError, response['message'] if response['err'] > 0
      response['result']
    end
  end
end
