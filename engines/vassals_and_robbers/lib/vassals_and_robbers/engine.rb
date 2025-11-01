# EXAMPLE: Это шаблонный файл для создания своего Engine
module VassalsAndRobbers
  class Engine < ::Rails::Engine
    isolate_namespace VassalsAndRobbers
    engine_name 'vassals_and_robbers'

    config.autoload_paths << root.join('app')
    config.eager_load_paths << root.join('app')
    
    # Исключаем concerns из автозагрузки Zeitwerk, они загружаются явно
    # чтобы избежать конфликтов именования (concerns находятся не в структуре namespace)
    initializer 'vassals_and_robbers.ignore_concerns' do |app|
      Rails.autoloaders.main.ignore(root.join('app', 'controllers', 'concerns'))
      Rails.autoloaders.main.ignore(root.join('app', 'models', 'vassals_and_robbers', 'concerns'))
    end

    # Добавляем путь к миграциям Engine, чтобы они запускались напрямую
    initializer 'vassals_and_robbers.add_migrations' do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end

    config.to_prepare do
      # Подключаем concerns только если активна игра vassals-and-robbers
      if ENV['ACTIVE_GAME'] == 'vassals-and-robbers'
        Rails.logger.info "[VassalsAndRobbers] Activating plugin concerns..."
        
        # Явно загружаем concerns модули перед использованием
        engine_root = VassalsAndRobbers::Engine.root
        
        # Загружаем concerns для моделей
        models_concerns_path = engine_root.join('app', 'models', 'vassals_and_robbers', 'concerns')
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
        
        # Подключаем concerns к моделям ядра
        ::Plant.include VassalsAndRobbers::Concerns::PlantExtensions if defined?(::Plant) && defined?(VassalsAndRobbers::Concerns::PlantExtensions)
        ::Country.include VassalsAndRobbers::Concerns::CountryExtensions if defined?(::Country) && defined?(VassalsAndRobbers::Concerns::CountryExtensions)
        ::GameParameter.include VassalsAndRobbers::Concerns::GameParameterExtensions if defined?(::GameParameter) && defined?(VassalsAndRobbers::Concerns::GameParameterExtensions)
        ::Player.include VassalsAndRobbers::Concerns::PlayerExtensions if defined?(::Player) && defined?(VassalsAndRobbers::Concerns::PlayerExtensions)
        
        # Подключаем concerns к контроллерам ядра
        if defined?(::PlantPlacesController) && defined?(VassalsAndRobbers::Concerns::PlantPlacesControllerExtensions)
          ::PlantPlacesController.include VassalsAndRobbers::Concerns::PlantPlacesControllerExtensions
        end
        
        Rails.logger.info "[VassalsAndRobbers] Plugin concerns activated"
        
        # Здесь можно добавить другие расширения моделей ядра:
        # ::Region.include VassalsAndRobbers::Concerns::RegionExtensions if defined?(::Region)
      end
    end

    initializer 'vassals_and_robbers.assets.precompile' do |app|
      app.config.assets.paths << root.join('app', 'assets', 'stylesheets')
      app.config.assets.paths << root.join('app', 'assets', 'javascripts')
    end
  end
end

