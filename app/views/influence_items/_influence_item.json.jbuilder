json.extract! influence_item, :id, :value, :player_id, :entity, :comment, :year, :created_at, :updated_at
json.player_name influence_item.player&.name
json.url influence_item_url(influence_item, format: :json)
