# EXAMPLE: Это шаблонный файл для создания своего Engine
module Artel
  class Engine < ::Rails::Engine
    isolate_namespace Artel
    engine_name 'artel'

    config.autoload_paths << root.join('app')
    config.eager_load_paths << root.join('app')
    
    # Исключаем concerns из автозагрузки Zeitwerk, они загружаются явно
    # чтобы избежать конфликтов именования (concerns находятся не в структуре namespace)
    initializer 'artel.ignore_concerns' do |app|
      Rails.autoloaders.main.ignore(root.join('app', 'controllers', 'concerns'))
      Rails.autoloaders.main.ignore(root.join('app', 'models', 'artel', 'concerns'))
    end

    # Добавляем путь к миграциям Engine, чтобы они запускались напрямую
    initializer 'artel.add_migrations' do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end

    config.to_prepare do
      # Подключаем concerns только если активна игра artel
      if ENV['ACTIVE_GAME'] == 'artel'
        Rails.logger.info "[Artel] Activating plugin concerns..."
        
        # Явно загружаем concerns модули перед использованием
        engine_root = Artel::Engine.root
        
        # Загружаем concerns для моделей
        models_concerns_path = engine_root.join('app', 'models', 'artel', 'concerns')
        if Dir.exist?(models_concerns_path)
          Dir.glob(models_concerns_path.join('*.rb')).each do |file|
            require_dependency file.to_s
          end
        end
        
        # Загружаем concerns для контроллеров
        controllers_concerns_path = engine_root.join('app', 'controllers', 'concerns')
        if Dir.exist?(controllers_concerns_path)
          Dir.glob(controllers_concerns_path.join('*.rb')).each do |file|
            require_dependency file.to_s
          end
        end
        
        Rails.logger.info "[Artel] Plugin concerns activated"
        Rails.logger.info "[Artel] ENV['ACTIVE_GAME'] = #{ENV['ACTIVE_GAME'].inspect}"
      end
    end

    initializer 'artel.assets.precompile' do |app|
      app.config.assets.paths << root.join('app', 'assets', 'stylesheets')
      app.config.assets.paths << root.join('app', 'assets', 'javascripts')
    end
  end
end


