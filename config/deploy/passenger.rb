namespace :passenger do
  desc "Update systemd service and Nginx with environment variables from .env.production"
  task :update_env do
    on roles(:app) do
      env_file = "#{current_path}/.env.production"
      shared_env_file = "#{shared_path}/.env.production"
      
      # Убеждаемся, что симлинк существует
      unless test("[ -L #{current_path}/.env.production ]")
        execute :ln, "-sfn", shared_env_file, env_file
      end
      
      if test("[ -f #{env_file} ]")
        # Читаем ACTIVE_GAME из .env.production
        active_game = capture(:bash, "-c", %Q{grep "^ACTIVE_GAME=" #{env_file} | cut -d'=' -f2 || echo ''}).strip
        
        if active_game && !active_game.empty?
          info "Updating configuration with ACTIVE_GAME=#{active_game}"
          
          # 1. Обновляем systemd service файл (если используется)
          service_file = "/etc/systemd/system/passenger.service"
          if test("[ -f #{service_file} ]")
            execute :bash, "-c", %Q{
              if ! grep -q "EnvironmentFile=" #{service_file}; then
                sudo sed -i '/\\[Service\\]/a\\EnvironmentFile=#{env_file}' #{service_file}
                sudo systemctl daemon-reload
              elif ! grep -q "EnvironmentFile=#{env_file}" #{service_file}; then
                sudo sed -i "s|EnvironmentFile=.*|EnvironmentFile=#{env_file}|" #{service_file}
                sudo systemctl daemon-reload
              fi
            }
          end
          
          # 2. Обновляем Nginx конфигурацию для Passenger (если используется)
          # Passenger может использовать passenger_env_var для передачи переменных
          nginx_config = "/etc/nginx/sites-available/epoha.igroteh.su"
          if test("[ -f #{nginx_config} ]")
            # Проверяем, есть ли уже passenger_env_var для ACTIVE_GAME
            unless capture(:bash, "-c", "grep -q 'passenger_env_var ACTIVE_GAME' #{nginx_config} || echo 'not found'").include?("ACTIVE_GAME")
              execute :bash, "-c", %Q{
                # Добавляем passenger_env_var после passenger_app_env
                sudo sed -i '/passenger_app_env production;/a\\        passenger_env_var ACTIVE_GAME #{active_game};' #{nginx_config}
                sudo nginx -t && sudo systemctl reload nginx || true
              }
            else
              # Обновляем существующий passenger_env_var
              execute :bash, "-c", %Q{
                sudo sed -i 's|passenger_env_var ACTIVE_GAME .*|passenger_env_var ACTIVE_GAME #{active_game};|' #{nginx_config}
                sudo nginx -t && sudo systemctl reload nginx || true
              }
            end
          end
        end
      else
        warn ".env.production file not found at #{env_file} or #{shared_env_file}"
      end
    end
  end

  desc "Restart Passenger application server"
  task :restart do
    invoke 'passenger:update_env'
    on roles(:app) do
      execute :sudo, :systemctl, :restart, :passenger
      puts "Passenger successfully restarted"
    end
  end

  task :stop do
    on roles(:app) do
      execute :sudo, :systemctl, :stop, :passenger
      puts "Passenger successfully stoped"
    end
  end

  task :start do
    invoke 'passenger:update_env'
    on roles(:app) do
      execute :sudo, :systemctl, :start, :passenger
      puts "Passenger successfully started"
    end
  end

  desc "Show Passenger status"
  task :status do
    on roles(:app) do
      execute :sudo, :systemctl, :status, :passenger
    end
  end
end