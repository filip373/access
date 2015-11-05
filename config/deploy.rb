Airbrussh.configure do |config|
  config.command_output = true
end

set :application, 'access'
set :repo_url, 'git://github.com/netguru/access.git'
set :deploy_to, ENV["DEPLOY_PATH"]

set :docker_copy_data, %w(config/sec_config.yml config/keys)
set :docker_volumes, -> { ["#{fetch(:deploy_to)}/shared/log:/var/www/app/log"] }
set :docker_additional_options, -> { "--env-file #{fetch(:deploy_to)}/shared/envfile" }
