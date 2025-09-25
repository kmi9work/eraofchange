json.extract! building, :id, :params, :is_paid, :fined, :settlement_id, :income, :created_at, :updated_at
json.building_level do 
  json.partial! "building_levels/building_level", building_level: building.building_level
end
json.settlement_name building.settlement&.name
json.building_type_name building.building_level&.building_type&.name
json.building_level_name building.building_level&.name
json.building_level_level building.building_level&.level
json.url building_url(building, format: :json)
