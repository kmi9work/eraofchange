# Загрузка переменных окружения из .env.production (если существует)
# Используется для управления ACTIVE_GAME в production
# Примечание: основная загрузка происходит в config/application.rb (before_initialize)
# Этот файл оставлен для совместимости и дополнительной загрузки, если нужно

# Дополнительная проверка и логирование (выполняется после инициализации)
Rails.application.config.after_initialize do
  if Rails.env.production?
    env_file = Rails.root.join('.env.production')
    if File.exist?(env_file)
      Rails.logger.info "[LoadEnv] Verifying ACTIVE_GAME: #{ENV['ACTIVE_GAME'] || 'not set'}"
      Rails.logger.info "[LoadEnv] Country.alliances_enabled: #{Country.alliances_enabled}" if defined?(Country)
    else
      Rails.logger.warn "[LoadEnv] .env.production file not found at #{env_file}"
    end
  end
end

