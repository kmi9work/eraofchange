# EXAMPLE: Это шаблонный файл для создания своего Engine
namespace :vassals_and_robbers do
  namespace :db do
    namespace :seed do
      # Создаём задачи для каждого seed файла отдельно
      task :_load_seeds => :environment do
        # Эта задача только для загрузки окружения
      end
      
      engine_root = VassalsAndRobbers::Engine.root rescue nil
      if engine_root
        Dir[File.join(engine_root, 'db', 'seeds', '*.rb')].each do |filename|
          task_name = File.basename(filename, '.rb').intern

          task task_name => :environment do
            puts "Loading seed: #{filename}"
            load(filename)
          end
        end
      end

      # Задача для загрузки всех seeds
      desc "Load all seeds for Vassals and Robbers engine"
      task :all => :environment do
        begin
          engine_root = VassalsAndRobbers::Engine.root
          Dir[File.join(engine_root, 'db', 'seeds', '*.rb')].sort.each do |filename|
            puts "Loading: #{filename}"
            load(filename)
          end
          puts "All Vassals and Robbers seeds loaded!"
        rescue => e
          puts "Error loading seeds: #{e.message}"
          puts e.backtrace.first(5)
          raise
        end
      end
    end

    # Создание новой миграции с timestamp префиксом
    desc "Generate a new migration for Vassals and Robbers engine"
    task :create_migration, [:name] => :environment do |t, args|
      unless args[:name]
        puts "Usage: rake vassals_and_robbers:db:create_migration[migration_name]"
        puts "Example: rake vassals_and_robbers:db:create_migration[create_vassals_table]"
        exit
      end

      engine_root = VassalsAndRobbers::Engine.root
      migrations_path = File.join(engine_root, 'db', 'migrate')
      timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
      migration_name = args[:name]
      class_name = migration_name.camelize
      
      filename = "#{timestamp}_#{migration_name}.rb"
      filepath = File.join(migrations_path, filename)

      migration_content = <<~RUBY
        # EXAMPLE: Это шаблонный файл для создания своего Engine
        class #{class_name} < ActiveRecord::Migration[7.0]
          def change
            # TODO: Добавьте вашу миграцию здесь
            # Пример:
            # create_table :vassals_and_robbers_table_name do |t|
            #   t.string :name
            #   t.timestamps
            # end
          end
        end
      RUBY

      File.write(filepath, migration_content)
      puts "Created migration: #{filepath}"
    end
  end
end

