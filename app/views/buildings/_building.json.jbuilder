json.extract! building, :id, :params, :is_paid, :fined, :settlement_id, :income, :created_at, :updated_at
json.building_level do 
  json.partial! "building_levels/building_level", building_level: building.building_level
end
json.url building_url(building, format: :json)
