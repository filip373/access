server ENV['STAGING_SERVER'], user: ENV['STAGING_USER'], roles: %w{web app db}
set :deploy_to, ENV["STAGING_DEPLOY_PATH"]
set :branch, "master"
