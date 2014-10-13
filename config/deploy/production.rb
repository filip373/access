require 'net/ssh/proxy/command'
server ENV['PRODUCTION_SERVER'], user: ENV['PRODUCTION_USER'], roles: %w{web app db}
set :ssh_options, proxy: Net::SSH::Proxy::Command.new("ssh #{ENV['GATEWAY']} -W %h:%p")
