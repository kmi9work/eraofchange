json.extract! player, :id, :name, :human, :job, :player_type, :family, :guild, :params
json.url player_url(player, format: :json)
