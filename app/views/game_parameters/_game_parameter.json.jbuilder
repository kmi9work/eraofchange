json.extract! game_parameter, :id, :title, :params, :created_at, :updated_at
json.url game_parameter_url(game_parameter, format: :json)
