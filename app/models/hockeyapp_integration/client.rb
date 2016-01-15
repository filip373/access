module HockeyAppIntegration
  class Client
    include HTTParty
    base_url 'https://rink.hockeyapp.net/api/2'
    headers 'Accept' => 'application/json',
            'X-HockeyAppToken' => AppConfig.hockey_app.token

    def get(url, options = {})
      self.class.get(url, options)
    end

    def post(url, options = {})
      self.class.post(url, options)
    end

    def put(url, options = {})
      self.class.put(url, options)
    end

    def delete(url, options = {})
      self.class.delete(url, options)
    end
  end
end
