GithubApp::Application.configure do
  config.cache_classes = false
  config.eager_load = true
  config.action_controller.perform_caching = false
  config.active_support.deprecation = :log
  config.consider_all_requests_local = true
  config.assets.debug = true
  config.assets.compile = true
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: 'localhost:3000' }
end
