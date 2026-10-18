namespace :db do
  namespace :seed do
    desc "Сиды движка many_teams (действия, знать и города Новгорода)"
    task many_teams: :environment do
      Dir[ManyTeams::Engine.root.join("db", "seeds", "*.rb")].sort.each do |filename|
        puts filename
        load filename
      end
    end
  end
end

namespace :game do
  desc "Игра many-teams: drop + create + migrate + seeds ядра + сиды движка"
  task many_teams: :environment do
    ENV["APP_VERSION"] = "many_teams"
    ENV["ACTIVE_GAME"] = ManyTeams::ACTIVE_GAME

    original_check = ENV["DISABLE_DATABASE_ENVIRONMENT_CHECK"]
    ENV["DISABLE_DATABASE_ENVIRONMENT_CHECK"] = "1"
    Rake::Task["db:clear_and_create_db:all"].invoke
    ENV["DISABLE_DATABASE_ENVIRONMENT_CHECK"] = original_check

    puts "Сидирую основное"
    Rake::Task["db:seed:all"].invoke
    puts "Сидирую many_teams"
    Rake::Task["db:seed:many_teams"].invoke
  end
end
