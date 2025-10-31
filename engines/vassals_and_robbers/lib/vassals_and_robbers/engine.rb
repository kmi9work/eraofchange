# EXAMPLE: Это шаблонный файл для создания своего Engine
module VassalsAndRobbers
  class Engine < ::Rails::Engine
    isolate_namespace VassalsAndRobbers
    engine_name 'vassals_and_robbers'

    config.autoload_paths << root.join('app')
    config.eager_load_paths << root.join('app')

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
        
        # Подключаем concerns к моделям ядра
        ::Plant.include VassalsAndRobbers::Concerns::PlantExtensions if defined?(::Plant)
        ::Country.include VassalsAndRobbers::Concerns::CountryExtensions if defined?(::Country)
        ::GameParameter.include VassalsAndRobbers::Concerns::GameParameterExtensions if defined?(::GameParameter)
        ::Player.include VassalsAndRobbers::Concerns::PlayerExtensions if defined?(::Player)
        
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

