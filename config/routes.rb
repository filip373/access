GithubApp::Application.routes.draw do
  root 'main#index'
  get '/auth/:provider/callback' => 'session#create'
  get '/logout' => 'session#destroy', as: 'logout'

  namespace :github do
    get 'show_diff' => 'github_integration#show_diff', as: 'show_diff'
    post 'sync' => 'github_integration#sync', as: 'sync'
    delete 'cleanup_teams' => 'github_integration#cleanup_teams', as: 'cleanup_teams'
  end

  namespace :google do
    get 'show_diff' => 'google_integration#show_diff', as: 'show_diff'
    post 'sync' => 'google_integration#sync', as: 'sync'
  end
end
