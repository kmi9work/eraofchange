json.array! @plant_levels do |plant_level|
  json.partial! "plant_levels/plant_level", plant_level: plant_level, tech_schools_open: @tech_schools_open
end
