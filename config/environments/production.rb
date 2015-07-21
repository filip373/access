GithubApp::Application.configure do
  config.cache_classes = true

  config.eager_load = true
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  config.log_level = :info
  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify

  config.log_formatter = ::Logger::Formatter.new



  if AppConfig.smtp?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :address => AppConfig.smtp.address,
      :port => 587,
      :domain => AppConfig.smtp.domain,
      :user_name => AppConfig.smtp.user_name,
      :password => AppConfig.smtp.password,
      :authentication => "plain"
    }
  end


end
