namespace :deploy do
  desc "Create shared directories"
  task :create_shared_dirs do
    on roles(:app) do
      execute :mkdir, "-p", "#{shared_path}/config"
      execute :mkdir, "-p", "#{shared_path}/tmp/sockets"
      execute :mkdir, "-p", "#{shared_path}/tmp/pids"
    end
  end
end
before "deploy:check", "deploy:create_shared_dirs"