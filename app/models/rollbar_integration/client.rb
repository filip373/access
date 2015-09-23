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
      options.deep_merge!(query: { access_token: read_token })
      response = self.class.get(url, options)
      fail ApiError, response['message'] if response['err'] > 0
      response['result']
    end

    def get_all_pages(url, options = {})
      list = []
      counter = 1
      loop do
        options = { query: { page: counter } }
        tmp_list = get(url, options)
        break if tmp_list.empty?
        list += tmp_list
        counter += 1
      end
      list
    end

    def post(url, options = {})
      options.deep_merge!(query: { access_token: write_token },
                          'Content-Type' => 'application/json')
      response = self.class.post(url, options)
      fail ApiError, response['message'] if response['err'] > 0
      response['result']
    end

    def put(url, options = {})
      options.deep_merge!(query: { access_token: write_token },
                          'Content-Type' => 'application/json')
      response = self.class.put(url, options)
      fail ApiError, response['message'] if response['err'] > 0
      response['result']
    end

    def delete(url, options = {})
      options.deep_merge!(query: { access_token: write_token },
                          'Content-Type' => 'application/json')
      fail_or_return(self.class.delete(url, options))
    end

    private

    def fail_or_return(response)
      fail ApiError, response['message'] if response['err'] > 0
      response['result']
    end
  end
end
