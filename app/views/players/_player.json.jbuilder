json.extract! player, :id, :name, :human, :job, :player_type, :family, :guild, :params, :income, :influence, :player_military_outlays
json.job player.job, partial: "jobs/job", as: :job

json.influence_items player.influence_items.reverse, partial: "influence_items/influence_item", as: :influence_item
json.url player_url(player, format: :json)
