module EraGreat
  class Engine < ::Rails::Engine
    isolate_namespace EraGreat
    engine_name 'era_great'

    config.autoload_paths << root.join('app')
    config.eager_load_paths << root.join('app')

    initializer 'era_great.ignore_concerns' do |_app|
      Rails.autoloaders.main.ignore(root.join('app', 'controllers', 'concerns'))
      Rails.autoloaders.main.ignore(root.join('app', 'models', 'era_great', 'concerns'))
    end

    initializer 'era_great.add_migrations' do |app|
      unless app.root.to_s.match root.to_s
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end
    end

    config.to_prepare do
      if ENV['ACTIVE_GAME'] == 'era_great'
        Rails.logger.info "[EraGreat] Engine loaded (ACTIVE_GAME=era_great)"
      end
    end

    initializer 'era_great.assets.precompile' do |app|
      app.config.assets.paths << root.join('app', 'assets', 'stylesheets')
      app.config.assets.paths << root.join('app', 'assets', 'javascripts')
    end
  end
end

