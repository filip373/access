Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?

  provider :github,
           AppConfig.github.client_id,
           AppConfig.github.client_secret,
           scope: 'admin:org,repo'

  provider :google_oauth2,
           AppConfig.google.client_id,
           AppConfig.google.client_secret,
           scope: AppConfig.google.scope,
           prompt: 'select_account',
           image_aspect_ratio: 'square',
           image_size: 50,
           access_type: 'offline',
           approval_prompt: 'force',
           hd: AppConfig.google.main_domain
end
