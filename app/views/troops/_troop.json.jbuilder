json.extract! troop, :id, :troop_type, :is_hired, :is_paid, :power, :health, :damage, :max_health, :army_id, :created_at, :updated_at
json.url troop_url(troop, format: :json)
