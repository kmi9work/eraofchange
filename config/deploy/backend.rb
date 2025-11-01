# config/deploy/backend.rb
namespace :custom do
  require 'pathname'

  task :setup do  
    set :rbenv_type, :user  # или :system, если Ruby установлен системно
    set :rbenv_ruby, '3.2.2'  # Замените на вашу версию Ruby
    set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"

    set :application, "eraofchange"
    set :repo_url, "git@github.com:kmi9work/eraofchange.git"
    set :branch, 'depl'
    set :deploy_to, '/opt/era/eraofchange'
    set :current_path, -> { Pathname.new("#{deploy_to}/current") }
    set :shared_path, ->  { Pathname.new("#{deploy_to}/shared") }
    set :release_path, -> { Pathname.new("#{deploy_to}/releases/#{release_timestamp}") }

    set :passenger_ruby, '/home/deploy/.rbenv/shims/ruby'
    set :keep_releases, 3
    set :default_env, { 
      'RAILS_MASTER_KEY' => File.read('config/master.key').strip,
      'ERAOFCHANGE_DATABASE_PASSWORD' => File.read('config/database.key').strip
    }
  end

  desc "Custom backend deployment"
  task :deploy do
    invoke 'custom:setup'
    invoke 'deploy'
  end

  task :setup_config do
    on roles(:app) do
      execute :mkdir, "-p #{shared_path}/config"
      execute :mkdir, "-p #{shared_path}/tmp/sockets"
      execute :mkdir, "-p #{shared_path}/tmp/pids"
      execute :mkdir, "-p #{shared_path}/public/uploads"
      execute :mkdir, "-p #{shared_path}/log"

      upload!('config/database_prod.yml', "#{shared_path}/config/database.yml") if File.exist?('config/database_prod.yml')
      upload!('config/master.key', "#{shared_path}/config/master.key") if File.exist?('config/master.key')
      
      execute :chmod, "640 #{shared_path}/config/master.key" if test("[ -f #{shared_path}/config/master.key ]")
      
      # Создаем .env.production по умолчанию (base-game), если его еще нет или он пустой
      # НО: не перезаписываем, если файл уже содержит значение (оно могло быть установлено setup_vassals_env или setup_base_env)
      file_exists = test("[ -f #{shared_path}/.env.production ]")
      file_size = 0
      has_value = false
      
      if file_exists
        file_size = capture(:bash, "-c", %Q{test -s #{shared_path}/.env.production && echo "1" || echo "0"}).strip.to_i
        if file_size > 0
          has_value = capture(:bash, "-c", %Q{grep -q "^ACTIVE_GAME=" #{shared_path}/.env.production 2>/dev/null && echo "1" || echo "0"}).strip.to_i > 0
        end
      end
      
      # Создаем файл только если его нет или он пустой И не содержит ACTIVE_GAME
      unless file_exists && file_size > 0 && has_value
        execute :bash, "-c", %Q{echo "ACTIVE_GAME=base-game" > #{shared_path}/.env.production}
        execute :chmod, "644 #{shared_path}/.env.production"
      end
    end
  end

  desc "Перезалив базы"
  task :db_reinit do
    invoke 'custom:setup'
    on roles(:db) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          # Получаем параметры подключения из database.yml
          db_name = 'eraofchange_production'
          db_user = 'deploy'

          # 1. Дропаем базу (если существует)
          execute :psql, "-U #{db_user} -c 'DROP DATABASE IF EXISTS #{db_name}' postgres"

          # 2. Создаем новую базу
          execute :psql, "-U #{db_user} -c 'CREATE DATABASE #{db_name}' postgres"

          # 3. Выполняем миграции
          execute :rake, 'db:migrate'

          # 4. Заполняем данными
          execute :rake, 'db:seed:all'
        end
      end
    end
  end

  desc "Перезалив базы с vassals_and_robbers"
  task :db_reinit_vassals do
    invoke 'custom:setup'
    on roles(:db) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          # Получаем параметры подключения из database.yml
          db_name = 'eraofchange_production'
          db_user = 'deploy'

          # 1. Дропаем базу (если существует)
          execute :psql, "-U #{db_user} -c 'DROP DATABASE IF EXISTS #{db_name}' postgres"

          # 2. Создаем новую базу
          execute :psql, "-U #{db_user} -c 'CREATE DATABASE #{db_name}' postgres"

          # 3. Выполняем миграции
          execute :rake, 'db:migrate'

          # 4. Заполняем данными базовой игры
          execute :rake, 'db:seed:all'

          # 5. Заполняем данными vassals_and_robbers
          execute :rake, 'vassals_and_robbers:db:seed:all'
        end
      end
    end
  end

  task :setup_vassals_env do
    invoke 'custom:setup'
    on roles(:app) do
      # Убеждаемся, что директория shared существует
      execute :mkdir, "-p #{shared_path}"
      
      # Проверяем, существует ли файл и не пустой ли он
      file_exists = test("[ -f #{shared_path}/.env.production ]")
      file_size = 0
      if file_exists
        file_size = capture(:bash, "-c", %Q{test -s #{shared_path}/.env.production && echo "1" || echo "0"}).strip.to_i
      end
      
      # Обновляем файл .env.production с ACTIVE_GAME=vassals-and-robbers
      # Проверяем текущее значение, чтобы не перезаписывать, если уже правильное
      current_value = capture(:bash, "-c", %Q{grep "^ACTIVE_GAME=" #{shared_path}/.env.production 2>/dev/null | cut -d'=' -f2 || echo ''}).strip
      
      # Если файл не существует, пустой или содержит другое значение - обновляем
      if !file_exists || file_size == 0 || current_value != 'vassals-and-robbers'
        execute :bash, "-c", %Q{echo "ACTIVE_GAME=vassals-and-robbers" > #{shared_path}/.env.production}
        execute :chmod, "644 #{shared_path}/.env.production"
        reason = !file_exists ? "file didn't exist" : (file_size == 0 ? "file was empty" : "value was different")
        info "Updated .env.production with ACTIVE_GAME=vassals-and-robbers (#{reason})"
      else
        info ".env.production already has ACTIVE_GAME=vassals-and-robbers"
      end
      
      # Проверяем, что файл создан правильно
      execute :bash, "-c", "test -f #{shared_path}/.env.production && cat #{shared_path}/.env.production || echo 'ERROR: File not created'"
      
      # Создаем симлинк в current (если он уже существует)
      if test("[ -L #{current_path} ]") || test("[ -d #{current_path} ]")
        execute :ln, "-sfn", "#{shared_path}/.env.production", "#{current_path}/.env.production"
      end
    end
  end

  task :setup_base_env do
    invoke 'custom:setup'
    on roles(:app) do
      # Убеждаемся, что директория shared существует
      execute :mkdir, "-p #{shared_path}"
      
      # Проверяем, существует ли файл и не пустой ли он
      file_exists = test("[ -f #{shared_path}/.env.production ]")
      file_size = 0
      if file_exists
        file_size = capture(:bash, "-c", %Q{test -s #{shared_path}/.env.production && echo "1" || echo "0"}).strip.to_i
      end
      
      # Обновляем файл .env.production с ACTIVE_GAME=base-game
      # Проверяем текущее значение, чтобы не перезаписывать, если уже правильное
      current_value = capture(:bash, "-c", %Q{grep "^ACTIVE_GAME=" #{shared_path}/.env.production 2>/dev/null | cut -d'=' -f2 || echo ''}).strip
      
      # Если файл не существует, пустой или содержит другое значение - обновляем
      if !file_exists || file_size == 0 || current_value != 'base-game'
        execute :bash, "-c", %Q{echo "ACTIVE_GAME=base-game" > #{shared_path}/.env.production}
        execute :chmod, "644 #{shared_path}/.env.production"
        reason = !file_exists ? "file didn't exist" : (file_size == 0 ? "file was empty" : "value was different")
        info "Updated .env.production with ACTIVE_GAME=base-game (#{reason})"
      else
        info ".env.production already has ACTIVE_GAME=base-game"
      end
      
      # Проверяем, что файл создан правильно
      execute :bash, "-c", "test -f #{shared_path}/.env.production && cat #{shared_path}/.env.production || echo 'ERROR: File not created'"
      
      # Создаем симлинк в current (если он уже существует)
      if test("[ -L #{current_path} ]") || test("[ -d #{current_path} ]")
        execute :ln, "-sfn", "#{shared_path}/.env.production", "#{current_path}/.env.production"
      end
    end
  end


  task :r do
    on roles(:app) do
      execute :sudo, :systemctl, :stop, :passenger
    end
  end






end

# Хуки должны быть вне namespace
before 'deploy:check:linked_files', 'custom:setup_config'
#after 'deploy:publishing', 'deploy:restart'

append :linked_files, "config/database.yml", 'config/master.key', '.env.production'
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"






