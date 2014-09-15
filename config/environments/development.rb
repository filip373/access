GithubApp::Application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.action_controller.perform_caching = false
  config.active_support.deprecation = :log

  config.assets.debug = true

end
