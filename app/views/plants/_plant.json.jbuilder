json.extract! plant, :id, :comments, :name_of_plant, :economic_subject, :credit, :params, :plant_level_id, :plant_place_id, :economic_subject_id, :economic_subject_type, :created_at, :updated_at
# Признак «Технические училища» — по государству ЗЕМЕЛЬ предприятия (открыта в
# Москве → бонус только на московских землях), поэтому он лежит и внутри
# plant_level, и рядом с предприятием. Справочник /plant_levels.json отдаёт
# прежний глобальный статус текущего государства.
json.tech_schools_open plant.tech_schools_open?
json.plant_level do
  json.partial! "plant_levels/plant_level", plant_level: plant.plant_level, tech_schools_open: plant.tech_schools_open?
end
if plant.plant_place
  json.plant_place do
    json.id plant.plant_place.id
    json.name plant.plant_place.name
    if plant.plant_place.region
      region = plant.plant_place.region
      json.region_id region.id
      json.region_name region.name
      json.region_country_id region.country_id
      json.region_country_name region.country&.name
    end
  end
end
json.url plant_url(plant, format: :json)
