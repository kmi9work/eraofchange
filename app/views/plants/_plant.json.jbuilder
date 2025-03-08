json.extract! plant, :id, :comments, :name_of_plant, :plant_level, :plant_place, :economic_subject, :credit, :params
json.partial! "plant_levels/plant_level", plant_level: plant.plant_level
json.url plant_url(plant, format: :json)
