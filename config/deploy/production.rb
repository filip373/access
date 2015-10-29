require 'net/ssh/proxy/command'
server ENV["ACCESS_SERVER_HOST"], user: ENV["ACCESS_SERVER_USER"], roles: %w(app web db)

if ENV["GATEWAY"]
  set :ssh_options, proxy: Net::SSH::Proxy::Command.new("ssh #{ENV['GATEWAY']} -W %h:%p")
end

set :branch, "docker"
set :stage,  "production"
