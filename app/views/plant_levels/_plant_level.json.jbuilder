json.extract! plant_level, :id, :level, :deposit, :formulas, :price, :plant_type_id, :created_at, :updated_at
fc = plant_level.formula_conversion
json.formula_from fc['from']
json.formula_to fc['to']
json.tech_schools_open tech_schools_open
json.plant_type do
  pt = plant_level.plant_type
  if pt
    json.id pt.id
    json.name pt.name
    json.icon pt.respond_to?(:icon) ? pt.icon : nil
    json.icon_url "/images/plant_types/#{pt.id}.png"
    json.plant_category do
      pc = pt.plant_category
      if pc
        json.id pc.id
        json.name pc.name
        json.is_extractive pc.is_extractive
        json.icon pc.respond_to?(:icon) ? pc.icon : nil
        json.icon_url "/images/plant_categories/#{pc.id}.png"
      else
        json.nil!
      end
    end
  else
    json.nil!
  end
end
json.url plant_level_url(plant_level, format: :json)
