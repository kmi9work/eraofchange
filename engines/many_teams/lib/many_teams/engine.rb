module ManyTeams
  class Engine < ::Rails::Engine
    isolate_namespace ManyTeams
    engine_name "many_teams"

    config.autoload_paths << root.join("app")
    config.eager_load_paths << root.join("app")

    # Concerns лежат вне структуры namespace — грузим их явно (как в artel
    # и vassals_and_robbers), чтобы Zeitwerk не искал ManyTeams::Concerns по пути
    initializer "many_teams.ignore_concerns" do |_app|
      Rails.autoloaders.main.ignore(root.join("app", "models", "many_teams", "concerns"))
    end

    # Миграции движка попадают в общий прогон db:migrate
    initializer "many_teams.add_migrations" do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    # Маршруты движка монтируются сами: ядро не правится
    initializer "many_teams.mount_routes" do |app|
      app.routes.append do
        mount ManyTeams::Engine => "/many_teams"
      end
    end

    config.to_prepare do
      ManyTeams::Extensions.install! if ManyTeams.active?
    end

    initializer "many_teams.assets.precompile" do |app|
      app.config.assets.paths << root.join("app", "assets", "stylesheets")
    end
  end
end
