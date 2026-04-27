require_relative "boot"

require "rails/all"

# Устанавливаем активную игру для плагина vassals-and-robbers
ENV['ACTIVE_GAME'] ||= 'vassals-and-robbers'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module First
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Загружаем .env.production ДО инициализации engines, чтобы ACTIVE_GAME был доступен
    # Это критично для правильной активации плагинов (например, vassals_and_robbers)
    config.before_initialize do
      if Rails.env.production?
        env_file = Rails.root.join('.env.production')
        if File.exist?(env_file)
          Rails.logger.info "[Application] Loading environment variables from .env.production" if defined?(Rails.logger)
          File.readlines(env_file).each do |line|
            line.strip!
            next if line.empty? || line.start_with?('#')
            
            if line.include?('=')
              key, value = line.split('=', 2)
              ENV[key.strip] = value.strip if key && value
            end
          end
          Rails.logger.info "[Application] ACTIVE_GAME is now: #{ENV['ACTIVE_GAME'] || 'not set'}" if defined?(Rails.logger)
        end
      end
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.active_record.yaml_column_permitted_classes = [
      ActiveSupport::TimeWithZone,
      ActiveSupport::TimeZone,
      Time,
      Date,
      DateTime
    ]
  end
end
