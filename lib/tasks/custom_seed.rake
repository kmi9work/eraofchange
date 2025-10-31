# lib/tasks/custom_seed.rake

namespace :db do
  namespace :clear_and_create_db do
    task all: :environment do
      puts "Удаляю старую базу"
      Rake::Task['db:drop'].invoke
      puts "Создаю новую базу"
      Rake::Task['db:create'].invoke
      puts "Делаю миграции"
      Rake::Task['db:migrate'].invoke  
    end
  end

  namespace :seed do
    Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].each do |filename|
      task_name = File.basename(filename, '.rb').intern

      # Now we will create multiple tasks by each file name inside db/seeds directory. 

      task task_name => :environment do
        load(filename)
      end
    end

    # This is for if you want to run all seeds inside db/seeds directory
    task all: :environment do
      Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each do |filename|
        puts filename
        load(filename)
      end
    end

    task vassals: :environment do
      Dir[File.join(Rails.root, 'engines', 'vassals_and_robbers', 'db', 'seeds', '*.rb')].sort.each do |filename|
        puts filename
        load(filename)
      end
    end
  end
end


namespace :game do 
#rake game:core
  task core: :environment  do
    Rake::Task['db:clear_and_create_db:all'].invoke 
    puts "Сидирую основное"
    Rake::Task['db:seed:all'].invoke 
  end
#rake game:vassals
  task vassals: :environment do
    Rake::Task['game:core'].invoke    
    Rake::Task['db:seed:vassals'].invoke
  end




end

