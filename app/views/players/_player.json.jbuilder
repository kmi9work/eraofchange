json.extract! player, :id, :name, :human, :job, :player_type, :family, :guild, :params, :income, :player_military_outlays
json.job player.job, partial: "jobs/job", as: :job
json.url player_url(player, format: :json)
