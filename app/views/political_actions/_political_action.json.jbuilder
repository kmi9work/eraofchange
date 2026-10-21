json.extract! political_action, :id, :year, :success, :params, :political_action_type, :player, :country_id, :created_at, :updated_at
json.job_name political_action.job&.name
json.action_name political_action.political_action_type&.name
json.country political_action.country && { id: political_action.country.id, name: political_action.country.name, short_name: political_action.country.short_name }
json.url political_action_url(political_action, format: :json)
