json.extract! job, :id, :name, :params, :created_at, :updated_at
json.players job.players, partial: "players/player", as: :player
json.political_action_types job.political_action_types, partial: "political_action_types/political_action_type", as: :political_action_type
json.political_actions job.political_actions, partial: "political_actions/political_action", as: :political_action
json.url job_url(job, format: :json)
