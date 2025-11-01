# Загрузка переменных окружения из .env.production (если существует)
# Используется для управления ACTIVE_GAME в production
if Rails.env.production? && File.exist?(Rails.root.join('.env.production'))
  env_file = Rails.root.join('.env.production')
  File.readlines(env_file).each do |line|
    line.strip!
    next if line.empty? || line.start_with?('#')
    
    if line.include?('=')
      key, value = line.split('=', 2)
      ENV[key.strip] = value.strip if key && value
    end
  end
end

