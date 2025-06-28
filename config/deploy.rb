# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

namespace :backend do 
  task :deploy do
    require_relative 'deploy/passenger.rb'
    require_relative 'deploy/backend.rb'
    invoke 'custom:deploy'
  end
 
  task :reinit do
    require_relative 'deploy/backend.rb'
    require_relative 'deploy/passenger.rb'
    invoke 'passenger:stop'
    invoke 'custom:db_reinit'
    invoke 'passenger:start'
  end
end

namespace :frontend do
  task :deploy do
    require_relative 'deploy/frontend.rb'
    require_relative 'deploy/passenger.rb'
    invoke 'passenger:stop'
    invoke 'custom:front_deploy'
    invoke 'passenger:start'
  end
end

before 'deploy:updating',   'passenger:stop'
after  'deploy:publishing', 'passenger:start'