# lib/tasks/custom_seed.rake

# Загрузка сидов движка — одна точка для всех путей сидирования.
#
# Почему так: `db:seed:all` в этом файле перекрыт и грузит ТОЛЬКО db/seeds/*.rb,
# сиды движка в него не входят. Раньше их грузил деплой отдельным
# `rails runner 'Dir["engines/$ENGINE/db/seeds/*.rb"]'`, но `$ENGINE` стоит внутри
# одинарных кавычек и на сервере не раскрывался: шелл оставлял литерал `$ENGINE`,
# Ruby-глоб не находил файлов, `runner` выходил с кодом 0 — сиды движка молча не
# загружались, а деплой печатал «✓ Сиды успешно загружены».
#
# Теперь движок передаётся переменной ERA_ENGINE_SEEDS (каталог в engines/), путь
# считается от Rails.root (а не от текущего каталога), а пустой список файлов —
# это ошибка, а не тихий успех.
module EraEngineSeeds
  module_function

  def dir(name)
    Rails.root.join('engines', name.to_s, 'db', 'seeds')
  end

  def files(name)
    Dir[dir(name).join('*.rb')].sort
  end

  # Имя движка, сиды которого надо предложить, — по ACTIVE_GAME («many-teams» →
  # many_teams). nil, если игра ядра или у движка нет каталога сидов.
  def engine_for_active_game
    key = ENV['ACTIVE_GAME'].to_s.strip
    return nil if key.empty? || %w[core base-game].include?(key)

    name = key.tr('-', '_')
    Dir.exist?(dir(name)) ? name : nil
  end

  def load!(name)
    name = name.to_s.strip
    abort 'ERA_ENGINE_SEEDS не задан: укажите каталог движка, например many_teams' if name.empty?

    unless Dir.exist?(dir(name))
      abort "Сиды движка «#{name}» не найдены: #{dir(name)} отсутствует"
    end

    list = files(name)
    abort "В #{dir(name)} нет ни одного *.rb — сиды движка не загружены" if list.empty?

    puts "[сиды движка #{name}] файлов: #{list.size}"
    list.each do |filename|
      puts "  #{filename}"
      load(filename)
    end
    puts "[сиды движка #{name}] загружено файлов: #{list.size}"
    list.size
  end
end

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

      # Сиды движка: явно (ERA_ENGINE_SEEDS=<каталог>) либо предупреждением, что их нет.
      if ENV['ERA_ENGINE_SEEDS'].to_s.strip.empty?
        engine = EraEngineSeeds.engine_for_active_game
        if engine
          puts ''
          puts "⚠ Загружены только сиды ЯДРА: сиды движка #{engine} не загружены."
          puts "  Движок активен (ACTIVE_GAME=#{ENV['ACTIVE_GAME']}), его сиды лежат в engines/#{engine}/db/seeds."
          puts "  Полный набор: ERA_ENGINE_SEEDS=#{engine} bin/rails db:seed:all"
        end
      else
        EraEngineSeeds.load!(ENV['ERA_ENGINE_SEEDS'])
      end
    end

    # Сиды движка без пересоздания базы: ERA_ENGINE_SEEDS=many_teams bin/rails db:seed:engine
    desc 'Сиды движка из engines/<ERA_ENGINE_SEEDS>/db/seeds/*.rb (без ядра)'
    task engine: :environment do
      EraEngineSeeds.load!(ENV['ERA_ENGINE_SEEDS'])
    end

    task vassals: :environment do
      Dir[File.join(Rails.root, 'engines', 'vassals_and_robbers', 'db', 'seeds', '*.rb')].sort.each do |filename|
        puts filename
        load(filename)
      end
    end

    task artel: :environment do
      artel_seeds = File.join(Rails.root, 'engines', 'artel', 'db', 'seeds', '*.rb')
      Dir[artel_seeds].sort.each do |filename|
        puts filename
        load(filename)
      end
    end
  end
end


namespace :game do 
  # rake game:core
  task core: :environment do
    ENV['APP_VERSION'] = 'core'
    # Отключаем проверку среды для операций с БД
    original_check = ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK']
    ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = '1'
    Rake::Task['db:clear_and_create_db:all'].invoke 
    ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = original_check
    puts "Сидирую основное"
    Rake::Task['db:seed:all'].invoke 
  end

  # rake game:vassals
  task vassals: :environment do
    ENV['APP_VERSION'] = 'vassals'
    # Сиды движка грузятся в конце db:seed:all (как и раньше — после ядра).
    ENV['ERA_ENGINE_SEEDS'] = 'vassals_and_robbers'
    original_check = ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK']
    ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = '1'
    Rake::Task['db:clear_and_create_db:all'].invoke 
    ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = original_check
    Rake::Task['db:seed:all'].invoke 
  end

  # rake game:artel
  task artel: :environment do
    ENV['APP_VERSION'] = 'artel'
    ENV['ACTIVE_GAME'] = 'artel'
    ENV['ERA_ENGINE_SEEDS'] = 'artel'
    original_check = ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK']
    ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = '1'
    Rake::Task['db:clear_and_create_db:all'].invoke
    ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = original_check
    puts "Сидирую основное"
    Rake::Task['db:seed:all'].invoke
  end
end

