namespace :passenger do
  desc "Restart Passenger application server"
  task :restart do
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