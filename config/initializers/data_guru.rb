DataGuru.configure do |config|
  config.api_url      = AppConfig.dataguru.api_url
  config.access_token = AppConfig.dataguru.access_token
end
