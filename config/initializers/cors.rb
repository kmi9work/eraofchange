Rails.application.config.middleware.insert_before 0, Rack::Cors do
  # Для веб-приложения (с credentials для сессий)
  allow do
    origins 'http://192.168.1.101:5173', 'http://localhost:5173', 'http://192.168.1.45:5173'
   
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
  
  # Для мобильного приложения (React Native/Expo часто не отправляет origin)
  allow do
    origins '*'
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: false
  end
end

 # https://pragmaticstudio.com/tutorials/rails-session-cookies-for-api-authentication
