json.extract! resource, :id, :name, :params, :country_id, :identificator, :created_at, :updated_at
# Иконка по конвенции: /images/resources/#{identificator}.png (фронт может подставлять identificator)
json.icon_url "/images/resources/#{resource.identificator}.png"
json.url resource_url(resource, format: :json)


