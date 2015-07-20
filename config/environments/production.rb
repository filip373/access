GithubApp::Application.configure do
  config.cache_classes = true

  config.eager_load = true
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  config.log_level = :info
  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify

  config.log_formatter = ::Logger::Formatter.new
  config.force_ssl = true
end
