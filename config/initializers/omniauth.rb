Rails.application.config.middleware.use OmniAuth::Builder do
	provider :developer unless Rails.env.production?
	provider :github, AppConfig.github.client_id, AppConfig.github.client_secret, scope: 'admin:org,repo'
end
