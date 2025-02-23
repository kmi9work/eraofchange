json.extract! guild, :id, :name, :created_at, :updated_at
json.players guild.players.order(:name), partial: "players/player", as: :player
json.url guild_url(guild, format: :json)
