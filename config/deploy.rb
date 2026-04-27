# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

#Развертывание бекэнда (базовая версия). Команда cap production backend:deploy
#Заполнение базы (базовая версия).       Команда cap production backend:reinit

#Развертывание бекэнда (vassals_and_robbers). Команда cap production backend:deploy_vassals
#Заполнение базы (vassals_and_robbers).        Команда cap production backend:reinit_vassals
#Развертывание бекэнда (artel).                Команда cap production backend:deploy_artel
#Заполнение базы (artel).                      Команда cap production backend:reinit_artel

namespace :backend do 
  task :deploy do
    require_relative 'deploy/passenger.rb'
    require_relative 'deploy/backend.rb'
    invoke 'passenger:stop'
    invoke 'custom:setup_base_env'
    invoke 'custom:deploy'
    invoke 'passenger:start'
  end
 
  task :reinit do
    require_relative 'deploy/backend.rb'
    require_relative 'deploy/passenger.rb'
    invoke 'passenger:stop'
    invoke 'custom:db_reinit'
    invoke 'passenger:start'
  end

  task :deploy_vassals do
    require_relative 'deploy/passenger.rb'
    require_relative 'deploy/backend.rb'
    invoke 'passenger:stop'
    invoke 'custom:setup_vassals_env'
    invoke 'custom:deploy'
    invoke 'passenger:start'
  end

  task :reinit_vassals do
    require_relative 'deploy/backend.rb'
    require_relative 'deploy/passenger.rb'
    invoke 'passenger:stop'
    invoke 'custom:db_reinit_vassals'
    invoke 'custom:setup_vassals_env'
    invoke 'passenger:start'
  end

  task :deploy_artel do
    require_relative 'deploy/passenger.rb'
    require_relative 'deploy/backend.rb'
    invoke 'passenger:stop'
    invoke 'custom:setup_artel_env'
    invoke 'custom:deploy'
    invoke 'passenger:start'
  end

  task :reinit_artel do
    require_relative 'deploy/backend.rb'
    require_relative 'deploy/passenger.rb'
    invoke 'passenger:stop'
    invoke 'custom:db_reinit_artel'
    invoke 'custom:setup_artel_env'
    invoke 'passenger:start'
  end
end

#Развертывание фронтэнда (базовая версия). Команда cap production frontend:deploy
#Развертывание фронтэнда (vassals_and_robbers). Команда cap production frontend:deploy_vassals
namespace :frontend do
  task :deploy do
    require_relative 'deploy/frontend.rb'
    require_relative 'deploy/passenger.rb'
    invoke 'passenger:stop'
    invoke 'custom:front_deploy'
    invoke 'passenger:start'
  end

  task :deploy_vassals do
    require_relative 'deploy/frontend.rb'
    require_relative 'deploy/passenger.rb'
    invoke 'passenger:stop'
    invoke 'custom:front_deploy_vassals'
    invoke 'passenger:start'
  end
end

# before 'deploy:updating',   'passenger:stop'
# after  'deploy:publishing', 'passenger:start'