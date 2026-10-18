# Должность: держатели и политические действия — в разрезе государства (@jobs_country,
# по умолчанию текущее). Справочник должностей общий (Д3), поля те же.
country = @jobs_country || Country.current

json.extract! job, :id, :name, :params, :created_at, :updated_at
json.country_id country&.id
json.player_ids job.council_player_ids(country)
json.players job.council_players(country), partial: "players/player", as: :player
json.political_action_types job.political_action_types, partial: "political_action_types/political_action_type", as: :political_action_type
json.political_actions job.political_actions.where(country_id: country&.id), partial: "political_actions/political_action", as: :political_action
json.url job_url(job, format: :json)
