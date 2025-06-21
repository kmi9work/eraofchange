# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

set :application, "eraofchange"
set :repo_url, "git@github.com:kmi9work/eraofchange.git"
set :branch, 'depl'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/deploy/eraofchange"

set :passenger_restart_command, 'passenger-config restart-app'


set :rbenv_type, :user  # или :system, если Ruby установлен системно
set :rbenv_ruby, '3.2.2'  # Замените на вашу версию Ruby
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
