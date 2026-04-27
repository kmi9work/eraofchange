json.extract! political_action, :id, :year, :success, :params, :political_action_type, :player, :created_at, :updated_at
json.job_name political_action.job&.name
json.action_name political_action.political_action_type&.name
json.url political_action_url(political_action, format: :json)
