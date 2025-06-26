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


#Команада cap production deploy
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
      
      # Устанавливаем правильные права
      execute :chmod, "640 #{shared_path}/config/master.key" if test("[ -f #{shared_path}/config/master.key ]")
      execute :touch, "#{current_path}/tmp/restart.txt"
    end
  end

  
  

  # Хуки для выполнения задач
  before 'deploy:check:linked_files', 'deploy:setup_config'
  after 'deploy:publishing', 'deploy:restart'
end


#Команада cap production db:reinit
namespace :db do
  desc 'Полный сброс и инициализация БД (drop, create, migrate, seed)'
  task :reinit do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
               # Получаем параметры подключения из database.yml
          db_name = 'eraofchange_production'
          db_user = 'deploy'  # Замените на реального пользователя

          # Проверяем, что подключение к PostgreSQL есть
          execute :psql, "-U  #{db_user}  -d postgres, '--version' "

          # 1. Дропаем базу (если существует)
          execute :psql, "-U #{db_user} -c 'DROP DATABASE IF EXISTS #{db_name}' postgres"

          # 2. Создаем новую базу
          execute :psql, "-U #{db_user} -c 'CREATE DATABASE #{db_name}' postgres"

          # 3. Выполняем миграции
          execute :rake, 'db:migrate'

          # 4. Заполняем данными
          execute :rake, 'db:seed:all'

          # 5. Проверяем
          execute :psql, "-U #{db_user} -c '\\l' #{db_name} | grep #{db_name}"
        end
      end
    end
  end
end

append :linked_files, "config/database.yml", 'config/master.key'
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"

namespace :frontend do
  task :deploy do
    on roles(:app) do
      frontend_dir = "/opt/era/era_front"
      execute :git, :clone, "--depth 1", "git@github.com:kmi9work/era_front.git", frontend_dir unless test("[ -d #{frontend_dir} ]")
      within frontend_dir do
        execute :git, :pull
        execute :bash, '-lc', '"source ~/.nvm/nvm.sh && nvm install v22"'
        execute :bash, "-c", '"curl -fsSL https://get.pnpm.io/install.sh | sh -"'

        # Установка зависимостей через pnpm
        execute :bash, '-lc', '"source ~/.nvm/nvm.sh && export PATH=$HOME/.nvm/versions/node/v22/bin:$HOME/.local/share/pnpm:$PATH && pnpm install --ignore-scripts"'
        # Замена адреса
        execute :sed, '-i', "'s|VITE_PROXY=http://localhost:3000|VITE_PROXY=https://epoha.igroteh.su/backend|g'", "#{frontend_dir}/.env"

        # Сборка проекта 
        execute :bash, '-lc', '"source ~/.nvm/nvm.sh && /home/deploy/.local/share/pnpm/pnpm build"'
      end
    end
  end
end





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
