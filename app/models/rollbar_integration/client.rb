module RollbarIntegration
  class Client
    include HTTParty
    attr_accessor :read_token, :write_token
    base_uri 'https://api.rollbar.com/'

    def initialize(read_token:, write_token:)
      self.read_token = read_token
      self.write_token = write_token
    end

    def get(url, options = {})
      options.merge!(query: { access_token: read_token })
      response = self.class.get(url, options)
      raise ApiError, response['message'] if response['err'] > 0
      response['result']
    end

    def post(url, options = {})
      options.merge!(query: { access_token: write_token },
                     'Content-Type' => 'application/json')
      response = self.class.post(url, options)
      raise ApiError, response['message'] if response['err'] > 0
      response['result']
    end

    def put(url, options = {})
      options.merge!(query: { access_token: write_token },
                     'Content-Type' => 'application/json')
      response = self.class.put(url, options)
      raise ApiError, response['message'] if response['err'] > 0
      response['result']
    end
  end
end
