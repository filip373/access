GithubApp::Application.routes.draw do
  root 'github#index'
  get '/auth/github/callback' => 'session#create'

  resources :github, only: [:index] do
    collection do
      post :do_sync
      delete :cleanup_teams
    end
  end
end
