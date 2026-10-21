json.extract! technology_item, :id, :value, :technology_id, :country_id, :entity, :comment, :year, :created_at, :updated_at
json.country technology_item.country && { id: technology_item.country.id, name: technology_item.country.name, short_name: technology_item.country.short_name }
json.url technology_item_url(technology_item, format: :json)
