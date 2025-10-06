Rails.application.config.middleware.insert_before 0, Rack::Cors do
 allow do
  # Разрешаем все локальные адреса для разработки
  origins '*'
 
  resource '*',
    headers: :any,
    methods: [:get, :post, :put, :patch, :delete, :options, :head],
    credentials: false  # Отключаем credentials для мобильных приложений
  end
 end

 # https://pragmaticstudio.com/tutorials/rails-session-cookies-for-api-authentication


