json.extract! plant, :id, :comments, :name_of_plant, :plant_place, :economic_subject, :credit, :params, :plant_level_id, :plant_place_id, :economic_subject_id, :economic_subject_type, :created_at, :updated_at
json.plant_level do
  json.partial! "plant_levels/plant_level", plant_level: plant.plant_level
end
json.url plant_url(plant, format: :json)
