GithubApp::Application.routes.draw do
  root 'main#index'
  get '/auth/github/callback' => 'github_session#create'
  get '/auth/google_oauth2/callback' => 'google_session#create'
  get '/logout' => 'session#destroy', as: 'logout'
  get '/auth/failure' => 'session#failure'

  get 'github/show_diff' => 'github_integration#show_diff', as: 'github_show_diff'
  post 'github/sync' => 'github_integration#sync', as: 'github_sync'
  delete 'github/cleanup_teams' => 'github_integration#cleanup_teams', as: 'github_cleanup_teams'

  get 'google/show_diff' => 'google_integration#show_diff', as: 'google_show_diff'
  post 'google/sync' => 'google_integration#sync', as: 'google_sync'
end
