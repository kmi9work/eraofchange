json.extract! plant_type, :id, :name, :plant_category_id, :fossil_type_id, :created_at, :updated_at
json.icon plant_type.respond_to?(:icon) ? plant_type.icon : nil
# Картинка по конвенции (если есть файл); иначе фронт может использовать icon как класс иконки, напр. Remix Icon
json.icon_url "/images/plant_types/#{plant_type.id}.png"
json.plant_category do
  if plant_type.plant_category
    json.id plant_type.plant_category.id
    json.name plant_type.plant_category.name
    json.is_extractive plant_type.plant_category.is_extractive
    json.icon plant_type.plant_category.respond_to?(:icon) ? plant_type.plant_category.icon : nil
    json.icon_url "/images/plant_categories/#{plant_type.plant_category.id}.png"
  else
    json.nil!
  end
end
json.url plant_type_url(plant_type, format: :json)
