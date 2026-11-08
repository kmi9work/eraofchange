json.extract! settlement, :id, :name, :settlement_type_id, :settlement_type, :region_id, :income, :buildings, :map_x, :map_y, :created_at, :updated_at
# Уровень крепости (0 — нет): им клиент красит маркер на карте
json.fortress_level settlement.fortress_level
# Потолок уровня крепости в этой игре: в «Вассалах и разбойниках» он 1 (сид
# движка удаляет уровни 2-3), в остальных играх 3. Клиент мастеров по нему
# решает, показывать ли «Улучшить крепость» — правило живёт на сервере.
json.fortress_max_level(@fortress_max_level ||= BuildingLevel.where(building_type_id: BuildingType::DEFENCE).maximum(:level).to_i.nonzero? || 1)
# Ворота открыты (панель города на карте): штурм возможен без осадных орудий
json.open_gate settlement.params&.dig("open_gate")
json.player do 
  if settlement.player
    json.partial! "players/player", player: settlement.player
  end
end
json.buildings settlement.sorted_buildings, partial: "buildings/building", as: :building
json.url settlement_url(settlement, format: :json)

