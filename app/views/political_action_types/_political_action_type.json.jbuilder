json.extract! political_action_type, :id, :name, :icon, :action, :params, 
  :job, :description, :cost, :probability, :success, :failure, :created_at, :updated_at

json.url political_action_type_url(political_action_type, format: :json)
