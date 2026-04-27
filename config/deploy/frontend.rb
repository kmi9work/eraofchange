namespace :custom do
  require 'pathname'

    task :front_setup do
      set :application, "era_front"
      set :repo_url, "git@github.com:kmi9work/era_front.git"
     #set :branch, 'depl'
      set :deploy_to, '/opt/era/era_front'
      set :current_path, -> { Pathname.new("#{deploy_to}/current") }
      set :shared_path, ->  { Pathname.new("#{deploy_to}/shared") }
      set :release_path, -> { Pathname.new("#{deploy_to}/releases/#{release_timestamp}") }
      set :keep_releases, 3
    end

  task :front_deploy do
      invoke 'custom:front_setup'
      on roles(:app) do
        execute :git, :clone, "--depth 1", "git@github.com:kmi9work/era_front.git", fetch(:release_path) 
        within release_path do
          # Установка Node.js v22 (если еще не установлен)
          # Используем nvm для установки, но не для использования (nvm use не работает через SSH)
          execute :bash, '-lc', "export NVM_DIR=\"$HOME/.nvm\" && [ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\" && nvm install v22 2>/dev/null || true"
          
          # Установка pnpm (если еще не установлен)
          unless test("[ -f /home/deploy/.local/share/pnpm/pnpm ]")
            execute :bash, '-lc', "curl -fsSL https://get.pnpm.io/install.sh | sh -", raise_on_non_zero_exit: false
          end
          
          # Используем абсолютный путь к pnpm
          pnpm_path = '/home/deploy/.local/share/pnpm/pnpm'
          
          # Установка зависимостей через pnpm
          # Используем env для установки PATH глобально в одной команде
          execute :bash, '-c', 'NODE_BIN=$(ls -d $HOME/.nvm/versions/node/v22* 2>/dev/null | sort -V | tail -1)/bin && env PATH="$NODE_BIN:$PATH" '"#{pnpm_path}"' install --ignore-scripts'
          
          # Настройка .env файла
          execute :sed, '-i', "'s|VITE_PROXY=http://localhost:3000|VITE_PROXY=https://epoha.igroteh.su/backend|g'", ".env"
          
          # Устанавливаем VITE_ACTIVE_GAME=base-game
          if test("grep -q '^VITE_ACTIVE_GAME=' .env")
            execute :sed, '-i', "'s|^VITE_ACTIVE_GAME=.*|VITE_ACTIVE_GAME=base-game|g'", ".env"
          else
            execute :bash, "-c", "echo 'VITE_ACTIVE_GAME=base-game' >> .env"
          end

         # Сборка проекта
          # Используем env для установки PATH, чтобы все подпроцессы видели node
          execute :bash, '-c', 'NODE_BIN=$(ls -d $HOME/.nvm/versions/node/v22* 2>/dev/null | sort -V | tail -1)/bin && env PATH="$NODE_BIN:$PATH" '"#{pnpm_path}"' build'
          execute :mkdir, "-p #{current_path}"    
          execute :ln, '-sfn',  "#{release_path}/dist", "#{current_path}" 
        end
      end
   end

  task :front_deploy_vassals do
      invoke 'custom:front_setup'
      on roles(:app) do
        execute :git, :clone, "--depth 1", "git@github.com:kmi9work/era_front.git", fetch(:release_path) 
        within release_path do
          # Установка Node.js v22 (если еще не установлен)
          execute :bash, '-lc', "export NVM_DIR=\"$HOME/.nvm\" && [ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\" && nvm install v22 2>/dev/null || true"
          
          # Установка pnpm (если еще не установлен)
          unless test("[ -f /home/deploy/.local/share/pnpm/pnpm ]")
            execute :bash, '-lc', "curl -fsSL https://get.pnpm.io/install.sh | sh -", raise_on_non_zero_exit: false
          end
          
          # Используем абсолютный путь к pnpm
          pnpm_path = '/home/deploy/.local/share/pnpm/pnpm'
          
          # Установка зависимостей через pnpm
          # Используем env для установки PATH глобально в одной команде
          execute :bash, '-c', 'NODE_BIN=$(ls -d $HOME/.nvm/versions/node/v22* 2>/dev/null | sort -V | tail -1)/bin && env PATH="$NODE_BIN:$PATH" '"#{pnpm_path}"' install --ignore-scripts'
          
          # Настройка .env файла
          execute :sed, '-i', "'s|VITE_PROXY=http://localhost:3000|VITE_PROXY=https://epoha.igroteh.su/backend|g'", ".env"
          
          # Устанавливаем VITE_ACTIVE_GAME=vassals-and-robbers
          if test("grep -q '^VITE_ACTIVE_GAME=' .env")
            execute :sed, '-i', "'s|^VITE_ACTIVE_GAME=.*|VITE_ACTIVE_GAME=vassals-and-robbers|g'", ".env"
          else
            execute :bash, "-c", "echo 'VITE_ACTIVE_GAME=vassals-and-robbers' >> .env"
          end

         # Сборка проекта
          # Используем env для установки PATH, чтобы все подпроцессы видели node
          execute :bash, '-c', 'NODE_BIN=$(ls -d $HOME/.nvm/versions/node/v22* 2>/dev/null | sort -V | tail -1)/bin && env PATH="$NODE_BIN:$PATH" '"#{pnpm_path}"' build'
          execute :mkdir, "-p #{current_path}"    
          execute :ln, '-sfn',  "#{release_path}/dist", "#{current_path}" 
        end
      end
   end
end





  # #Установка фронта
# #Команда cap production frontend:deploy
# #TO DO: Сделать структуру папок как у бека (с номерами релизов и текущей версией)
# namespace :frontend do
#   task :deploy do
#     on roles(:app) do
#       frontend_dir = "/opt/era/era_front"
#       execute :git, :clone, "--depth 1", "git@github.com:kmi9work/era_front.git", frontend_dir unless test("[ -d #{frontend_dir} ]")
#       within frontend_dir do
#         #execute :git, :pull
#         execute :bash, '-lc', '"source ~/.nvm/nvm.sh && nvm install v22"'
#         execute :bash, "-c", '"curl -fsSL https://get.pnpm.io/install.sh | sh -"'

#         # Установка зависимостей через pnpm
#         execute :bash, '-lc', '"source ~/.nvm/nvm.sh && export PATH=$HOME/.nvm/versions/node/v22/bin:$HOME/.local/share/pnpm:$PATH && pnpm install --ignore-scripts"'
        
#         # Замена адреса
#         execute :sed, '-i', "'s|VITE_PROXY=http://localhost:3000|VITE_PROXY=https://epoha.igroteh.su/backend|g'", "#{frontend_dir}/.env"

#         # Сборка проекта 
#         execute :bash, '-lc', '"source ~/.nvm/nvm.sh && /home/deploy/.local/share/pnpm/pnpm build"'
#       end
#     end
#   end
# end
