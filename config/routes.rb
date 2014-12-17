GithubApp::Application.routes.draw do
  root 'main#index'
  get '/auth/github/callback' => 'github_integration/session#create'
  get '/auth/google_oauth2/callback' => 'google_integration/session#create'

  get 'github/show_diff' => 'github_integration/main#show_diff', as: 'github_show_diff'
  post 'github/sync' => 'github_integration/main#sync', as: 'github_sync'
  delete 'github/cleanup_teams' => 'github_integration/main#cleanup_teams', as: 'github_cleanup_teams'

  get 'google/show_diff' => 'google_integration/main#show_diff', as: 'google_show_diff'
  post 'google/sync' => 'google_integration/main#sync', as: 'google_sync'
end
