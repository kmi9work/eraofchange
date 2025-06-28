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
      # set :default_env, { 
      #   'RAILS_MASTER_KEY' => File.read('config/master.key').strip,
      #   'ERAOFCHANGE_DATABASE_PASSWORD' => File.read('config/database.key').strip
      # }
    end

  task :front_deploy do
      invoke 'custom:front_setup'
      on roles(:app) do
        execute :git, :clone, "--depth 1", "git@github.com:kmi9work/era_front.git", fetch(:release_path) 
        within release_path do
          execute :bash, '-lc', '"source ~/.nvm/nvm.sh && nvm install v22"'
          execute :bash, "-c", '"curl -fsSL https://get.pnpm.io/install.sh | sh -"'

          # Установка зависимостей через pnpm
          execute :bash, '-lc', '"source ~/.nvm/nvm.sh && export PATH=$HOME/.nvm/versions/node/v22/bin:$HOME/.local/share/pnpm:$PATH && pnpm install --ignore-scripts"'
          
          execute :sed, '-i', "'s|VITE_PROXY=http://localhost:3000|VITE_PROXY=https://epoha.igroteh.su/backend|g'", "#{fetch(:release_path)}/.env"

         # Сборка проекта 
          execute :bash, '-lc', '"source ~/.nvm/nvm.sh && /home/deploy/.local/share/pnpm/pnpm build"' 
          execute :mkdir, "-p #{current_path}"    
          execute :ln, '-s', "#{release_path}/dist", "#{current_path}" 
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
