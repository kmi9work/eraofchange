json.extract! plant_level, :id, :level, :deposit, :formulas, :price, :created_at, :updated_at
json.formula_conversion plant_level.formula_conversion
json.plant_type do
  json.id plant_level.plant_type&.id
  json.name plant_level.plant_type&.name
  json.plant_category do
    json.id plant_level.plant_type&.plant_category&.id
    json.name plant_level.plant_type&.plant_category&.name
  end
end
json.url plant_level_url(plant_level, format: :json)
