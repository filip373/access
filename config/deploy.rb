set :application, 'access'
set :repo_url, 'git://github.com/netguru/access.git'
set :deploy_to, ENV["DEPLOY_PATH"]
set :gateway, ENV['GATEWAY']
set :linked_files, %w{config/sec_config.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
