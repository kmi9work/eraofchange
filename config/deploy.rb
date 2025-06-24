# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

set :application, "eraofchange"
set :repo_url, "git@github.com:kmi9work/eraofchange.git"
set :branch, 'depl'

set :deploy_to, "/home/deploy/eraofchange"
# Passenger
set :passenger_restart_with_touch, true
set :passenger_ruby, '/home/deploy/.rbenv/shims/ruby'

#set :passenger_restart_command, 'passenger-config restart-app'

set :rbenv_type, :user  # или :system, если Ruby установлен системно
set :rbenv_ruby, '3.2.2'  # Замените на вашу версию Ruby
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"

namespace :deploy do
  # Задача для создания папок и файлов при первом деплое
  task :setup_config do
    on roles(:app) do
      # Создаем необходимые папки в shared
      execute :mkdir, "-p #{shared_path}/config"
      execute :mkdir, "-p #{shared_path}/tmp/sockets"
      execute :mkdir, "-p #{shared_path}/tmp/pids"
      execute :mkdir, "-p #{shared_path}/public/uploads"
      execute :mkdir, "-p #{shared_path}/log"

      # Копируем конфигурационные файлы
      upload!('config/database.yml', "#{shared_path}/config/database.yml") if File.exist?('config/database.yml')
      upload!('config/master.key', "#{shared_path}/config/master.key") if File.exist?('config/master.key')
      
      # Устанавливаем правильные права (раскомментируйте если нужно)
      #execute :chmod, "640 #{shared_path}/config/master.key" if test("[ -f #{shared_path}/config/master.key ]")
    end
  end

  desc 'Restart Passenger'
  task :restart do
    on roles(:app) do
      # Проверяем, существует ли systemd unit
      if test(:sudo, :systemctl, :status, :passenger)
        execute :sudo, :systemctl, :restart, :passenger
      else
        warn "Passenger systemd service not found, falling back to touch restart.txt"
        execute :touch, "#{current_path}/tmp/restart.txt"
      end
    end
  end

  # Хуки для выполнения задач
  before 'deploy:check:linked_files', :setup_config
  after 'deploy:publishing', :restart
end


append :linked_files, "config/database.yml", 'config/master.key'
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"


set :keep_releases, 3

set :default_env, { 
  'RAILS_MASTER_KEY' => File.read('config/master.key').strip,
  'ERAOFCHANGE_DATABASE_PASSWORD' => 'b1cf3cdaf6066b' #для теста
}


  #  after :migrate, :seed do
  #   on primary :db do
  #     within release_path do
  #       with rails_env: fetch(:stage) do
  #         execute :rake, 'db:seed:all'
  #       end
  #     end
  #   end
  # end
