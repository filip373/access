require 'net/ssh/proxy/command'
server ENV["ACCESS_SERVER_HOST"], user: ENV["ACCESS_SERVER_USER"], roles: %w(app web db)

if ENV["GATEWAY"]
  set :ssh_options, proxy: Net::SSH::Proxy::Command.new("ssh #{ENV['GATEWAY']} -W %h:%p")
end

set :branch, "production"
set :stage,  "production"

set :docker_dockerfile, "docker/production/Dockerfile"
set :docker_additional_options, -> { "--env-file #{fetch(:deploy_to)}/shared/envfile --cpu-quota 100000" }
