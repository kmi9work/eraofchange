json.extract! political_action, :id, :year, :success, :params, :political_action_type_id, :player_id, :created_at, :updated_at
json.url political_action_url(political_action, format: :json)
