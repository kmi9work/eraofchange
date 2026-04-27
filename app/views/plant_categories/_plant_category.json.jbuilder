json.extract! plant_category, :id, :name, :is_extractive, :created_at, :updated_at
json.icon plant_category.respond_to?(:icon) ? plant_category.icon : nil
json.icon_url "/images/plant_categories/#{plant_category.id}.png"
json.url plant_category_url(plant_category, format: :json)
