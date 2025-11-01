# Загрузка переменных окружения из .env.production (если существует)
# Используется для управления ACTIVE_GAME в production
# Этот initializer загружается ДО инициализации engines, чтобы гарантировать загрузку ACTIVE_GAME

if Rails.env.production?
  env_file = Rails.root.join('.env.production')
  if File.exist?(env_file)
    Rails.logger.info "[LoadEnv] Loading environment variables from .env.production at #{env_file}" if defined?(Rails.logger)
    File.readlines(env_file).each do |line|
      line.strip!
      next if line.empty? || line.start_with?('#')
      
      if line.include?('=')
        key, value = line.split('=', 2)
        ENV[key.strip] = value.strip if key && value
        Rails.logger.debug "[LoadEnv] Set #{key.strip}=#{value.strip}" if defined?(Rails.logger)
      end
    end
    Rails.logger.info "[LoadEnv] ACTIVE_GAME is now: #{ENV['ACTIVE_GAME'] || 'not set'}" if defined?(Rails.logger)
  else
    Rails.logger.warn "[LoadEnv] .env.production file not found at #{env_file}" if defined?(Rails.logger)
  end
end

