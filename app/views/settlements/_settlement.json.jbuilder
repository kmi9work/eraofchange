json.extract! settlement, :id, :name, :settlement_type_id, :region_id, :income, :buildings, :created_at, :updated_at
json.player do 
  if settlement.player
    json.partial! "players/player", player: settlement.player
  end
end
json.buildings settlement.buildings, partial: "buildings/building", as: :building
json.url settlement_url(settlement, format: :json)

