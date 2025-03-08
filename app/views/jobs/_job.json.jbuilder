json.extract! job, :id, :name, :params, :created_at, :updated_at
json.political_action_types job.political_action_types, partial: "political_action_types/political_action_type", as: :political_action_type
json.url job_url(job, format: :json)
