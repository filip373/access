require 'sidekiq/web'
GithubApp::Application.routes.draw do
  root 'main#index'
  get '/todays-logs', to: 'main#todays_logs', as: :todays_logs

  constraints lambda { |request| request.session[:gh_token].present? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  # AUTH

  scope :auth do
    namespace :google_oauth2, module: :google_integration do
      get '', to: 'session#new', as: ''
      get :callback, to: 'session#create'
    end

    namespace :github, module: :github_integration do
      get :callback, to: 'session#create'
    end
  end

  namespace :github, module: :github_integration do
    controller :main do
      get :show_diff
      get :calculate_diff
      get :refresh_cache
      post :sync
      delete :cleanup_teams
    end
    get 'generate_permissions', to: 'generate#permissions'
  end

  ## INTEGRATIONS

  namespace :google, module: :google_integration do
    controller :main do
      get :show_diff
      get :show_groups
      post :sync
      post :create_accounts
      delete :cleanup_groups
    end
    get 'generate_permissions', to: 'generate#permissions'
  end

  namespace :rollbar, module: :rollbar_integration do
    get 'generate_permissions', to: 'generate#permissions'
    controller :main do
      get :calculate_diff
      get :refresh_cache
      get :show_diff
      post :sync
      delete :cleanup_teams
    end
  end

  get 'generate_users', to: 'generate#users'

  namespace :toggl, module: :toggl_integration do
    get 'generate_permissions', to: 'generate#permissions'
    controller :main do
      get :show_diff
      post :sync
      delete :cleanup_teams
    end
  end
end
