json.extract! player, :id, :name, :human, :job, :player_type, :family, :guild, :params, :income, :influence, :player_military_outlays
json.job player.job, partial: "jobs/job", as: :job

influence_items = [
  InfluenceItem.new(
    id: 0,
    value: player.influence_buildings,
    comment: 'Влияние от зданий',
    player: player
  ),
  *player.influence_items
]

json.influence_items influence_items.reverse, partial: "influence_items/influence_item", as: :influence_item
json.url player_url(player, format: :json)
