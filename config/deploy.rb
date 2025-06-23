# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

set :application, "eraofchange"
set :repo_url, "git@github.com:kmi9work/eraofchange.git"
set :branch, 'depl'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/deploy/eraofchange"

#set :passenger_restart_command, 'passenger-config restart-app'


set :rbenv_type, :user  # или :system, если Ruby установлен системно
set :rbenv_ruby, '3.2.2'  # Замените на вашу версию Ruby
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"

namespace :deploy do
  # Задача для создания папок и файлов при первом деплое
  task :setup_config do
    on roles(:app) do
      # Создаем папки, если их нет
      execute :mkdir, "-p #{shared_path}/config"
      execute :mkdir, "-p #{shared_path}/config/credentials"
      execute :mkdir, "-p #{shared_path}/tmp/sockets"
      execute :mkdir, "-p #{shared_path}/tmp/pids"
      execute :mkdir, "-p #{shared_path}/public/uploads"

      # Копируем файлы с локальной машины на сервер (если они существуют)
      upload!('config/database.yml', "#{shared_path}/config/database.yml") if File.exist?('config/database.yml')
      upload!('config/master.key', "#{shared_path}/config/master.key") if File.exist?('config/master.key')
      upload!('config/credentials/production.key', "#{shared_path}/config/credentials") if File.exist?('config/credentials/production.key')
      upload!('config/credentials/production.yml.enc', "#{shared_path}/config/credentials") if File.exist?('config/credentials/production.yml.enc')

      # Даем правильные права
      # execute :chmod, "644 #{shared_path}/config/database.yml" if test("[ -f #{shared_path}/config/database.yml ]")
      # execute :chmod, "600 #{shared_path}/config/master.key" if test("[ -f #{shared_path}/config/master.key ]")
    end
  end

  # Вызываем задачу перед деплоем (только если папка `release_path` не существует)
  before 'deploy:check:linked_files', :setup_config
end


# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"
append :linked_files, 'config/credentials/production.key'
append :linked_files, 'config/credentials/production.yml.enc'

set :keep_releases, 3


#Rake::Task['deploy:assets:precompile'].clear_actions

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
