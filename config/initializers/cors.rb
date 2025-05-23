Rails.application.config.middleware.insert_before 0, Rack::Cors do
 allow do
  origins 'localhost:5173'#, 'your-app.com'
 
  resource '*',
    headers: :any,
    methods: [:get, :post, :put, :patch, :delete, :options, :head],
    credentials: true
  end
 end

 # https://pragmaticstudio.com/tutorials/rails-session-cookies-for-api-authentication
