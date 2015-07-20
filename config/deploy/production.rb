set :branch, "production"
server ENV["ACCESS_SERVER_HOST"], user: ENV["ACCESS_SERVER_USER"], roles: %w(web app db)
server ENV["ACCESS_SERVER_HOST_2"], user: ENV["ACCESS_SERVER_USER"], roles: %w(web app)
