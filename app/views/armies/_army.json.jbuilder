json.extract! army, :id, :name, :hidden, :settlement, :owner_id, :owner_type, :attack_power, :defense_power, :params, :created_at, :updated_at
if army.owner_type == 'Player'
  json.owner army.owner, partial: "players/player", as: :player
elsif army.owner_type == 'Country'
  json.owner army.owner, partial: "countries/country", as: :country
end

json.troops army.troops, partial: "troops/troop", as: :troop

json.url army_url(army, format: :json)
