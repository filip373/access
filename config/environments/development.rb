GithubApp::Application.configure do
  config.cache_classes = false
  config.eager_load = true
  config.action_controller.perform_caching = false
  config.active_support.deprecation = :log
  config.consider_all_requests_local = true
  config.assets.debug = true
  config.assets.compile = true
end
