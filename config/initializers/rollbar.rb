require 'rollbar/rails'
Rollbar.configure do |config|
  config.access_token = AppConfig.rollbar_token
  config.enabled = !(Rails.env.test? or Rails.env.development?)
  config.scrub_fields |= [:access_token]
end
