json.extract! building, :id, :params, :is_paid, :fined, :settlement_id, :income, :created_at, :updated_at
json.building_level do 
  json.partial! "building_levels/building_level", building_level: building.building_level
end
json.settlement_name building.settlement&.name
json.building_type_name building.building_level&.building_type&.name
json.building_level_name building.building_level&.name
json.building_level_level building.building_level&.level
# Влияние, привязанное к постройке (штрафы за неоплаченную церковь). Мастер
# видит его в диалоге удаления церкви и сам решает, удалять ли вместе с ней.
json.influence_items_count building.influence_items.count
json.influence_total building.influence_items.sum(:value)
json.influence_items building.influence_items.order(:id) do |item|
  json.id item.id
  json.value item.value
  json.comment item.comment
  json.year item.year
  json.player_name item.player&.name
end
json.url building_url(building, format: :json)
