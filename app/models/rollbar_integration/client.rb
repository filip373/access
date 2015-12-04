module RollbarIntegration
  class Client
    include HTTParty
    rattr_initialize :token
    base_uri 'https://api.rollbar.com/'

    def get(url, options = {})
      options.deep_merge!(query: { access_token: token })
      fail_or_return(self.class.get(url, options))
    end

    def get_all_pages(url, options = {})
      list = []
      list += get(url, options)
      list
    end

    def post(url, options = {})
      options.deep_merge!(query: { access_token: token },
                          'Content-Type' => 'application/json')
      fail_or_return(self.class.post(url, options))
    end

    def put(url, options = {})
      options.deep_merge!(query: { access_token: token },
                          'Content-Type' => 'application/json')
      fail_or_return(self.class.put(url, options))
    end

    def delete(url, options = {})
      options.deep_merge!(query: { access_token: token },
                          'Content-Type' => 'application/json')
      fail_or_return(self.class.delete(url, options))
    end

    private

    def fail_or_return(response)
      fail ApiError, response['message'] if response['err'] > 0
      result = response['result']
      return result.map { |e| Hashie::Mash.new(e) } if result.is_a? Array
      Hashie::Mash.new(result)
    end
  end
end
