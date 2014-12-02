GithubApp::Application.routes.draw do
  root 'github#index'
  get '/auth/:provider/callback' => 'session#create'
  get '/logout' => 'session#destroy', as: 'logout'

  resources :github, only: [:index] do
    collection do
      get :show_diff
      post :do_sync
      delete :cleanup_teams
    end
  end
end
