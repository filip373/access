Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?

  provider :github,
           AppConfig.github.client_id,
           AppConfig.github.client_secret,
           scope: 'admin:org,repo'
  provider(:JIRA,
           AppConfig.jira.consumer_key,
           OpenSSL::PKey::RSA.new(IO.read(AppConfig.jira.private_key_path)),
           client_options: { site: AppConfig.jira.site }) unless Rails.env.test?
end
