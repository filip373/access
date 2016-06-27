GithubApp::Application.configure do
  config.cache_classes = true

  config.eager_load = true
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  config.log_level = :info
  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify

  config.log_formatter = ::Logger::Formatter.new
  config.active_job.queue_adapter = :sidekiq

  # Lograge config
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    { params: event.payload[:params].reject { |k| %w(controller action).include? k } }
  end

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
