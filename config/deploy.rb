require 'capistrano/upload'

set :application, 'access'
set :repo_url, 'git://github.com/netguru/access.git'
set :deploy_to, ENV["DEPLOY_PATH"]
set :linked_files, %w{config/sec_config.yml}
set :linked_dirs, %w{bin log tmp vendor/bundle config/keys}
set :passenger_restart_with_touch, true
