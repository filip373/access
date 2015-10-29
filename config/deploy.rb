require 'capistrano/upload'

set :application, 'access'
set :repo_url, 'git://github.com/netguru/access.git'
set :deploy_to, ENV["DEPLOY_PATH"]
set :linked_files, %w{.dockerrc}
set :copy_files, %w(config/sec_config.yml config/keys)

namespace :deploy do
  after :updated, :copy_secret_files do
    on roles(:web) do
      within release_path do
        fetch(:copy_files).each do |file|
          execute :cp, "-aR #{shared_path}/#{file} #{release_path}/#{file}"
        end
      end
    end
  end

  after :copy_secret_files, :build do
    on roles(:web) do
      within release_path do
        execute "docker/#{fetch(:stage)}/build"
      end
    end
  end

  task :restart do
    on roles(:web) do
      within release_path do
        execute "docker/#{fetch(:stage)}/restart"
      end
    end
  end

  after :publishing, :restart
end
