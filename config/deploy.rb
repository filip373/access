Airbrussh.configure do |config|
  config.command_output = true
end

set :application, 'access'
set :repo_url, 'git://github.com/netguru/access.git'
set :deploy_to, ENV["DEPLOY_PATH"]

set :docker_volumes, [
  "#{shared_path}/config/keys:/var/www/app/config/keys",
  "#{shared_path}/config/sec_config.yml:/var/www/app/config/sec_config.yml",

  "#{shared_path}/log:/var/www/app/log",

  "#{fetch(:application)}_#{fetch(:stage)}_assets:/var/www/app/public/assets"
]
set :docker_additional_options, -> { "--env-file #{fetch(:deploy_to)}/shared/envfile" }
set :docker_links, %w(redis_ambassador:redis)
set :docker_apparmor_profile, "docker-ptrace"
