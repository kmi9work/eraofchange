json.extract! settlement, :id, :name, :settlement_type_id, :settlement_type, :region_id, :income, :buildings, :map_x, :map_y, :created_at, :updated_at
# Уровень крепости (0 — нет): им клиент красит маркер на карте
json.fortress_level settlement.fortress_level
json.player do 
  if settlement.player
    json.partial! "players/player", player: settlement.player
  end
end
json.buildings settlement.sorted_buildings, partial: "buildings/building", as: :building
json.url settlement_url(settlement, format: :json)

