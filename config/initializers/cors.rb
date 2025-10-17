Rails.application.config.middleware.insert_before 0, Rack::Cors do
 allow do
  origins 'http://192.168.145.*:5173', 'http://192.168.1.45:5173', '192.168.1.45:5173', '192.168.1.*:5173', 'localhost:5173', ' 192.168.1.45:5173', ' 192.168.*.*:8081', 'localhost:8081', 'localhost:19000', 'localhost:19006', '192.168.1.109:8081', '192.168.1.101:19006'
 
  resource '*',
    headers: :any,
    methods: [:get, :post, :put, :patch, :delete, :options, :head],
    credentials: true
  end
 end

 # https://pragmaticstudio.com/tutorials/rails-session-cookies-for-api-authentication
