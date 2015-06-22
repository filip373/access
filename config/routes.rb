GithubApp::Application.routes.draw do
  root 'main#index'
  get '/auth/github/callback' => 'github_integration/session#create'
  get '/auth/google_oauth2' => 'google_integration/session#new', as: 'google_oauth2'
  get '/auth/google_oauth2/callback' => 'google_integration/session#create', as: 'google_oauth2_callback'

  get 'github/show_diff' => 'github_integration/main#show_diff', as: 'github_show_diff'
  post 'github/sync' => 'github_integration/main#sync', as: 'github_sync'
  delete 'github/cleanup_teams' => 'github_integration/main#cleanup_teams', as: 'github_cleanup_teams'

  get 'google/generate_permissions' => 'google_integration/generate#permissions'
  get 'google/show_diff' => 'google_integration/main#show_diff', as: 'google_show_diff'
  post 'google/sync' => 'google_integration/main#sync', as: 'google_sync'
  post 'google/create_accounts' => 'google_integration/main#create_accounts', as: 'create_accounts'
  delete 'google/cleanup_groups' => 'google_integration/main#cleanup_groups', as: 'google_cleanup_groups'

end
