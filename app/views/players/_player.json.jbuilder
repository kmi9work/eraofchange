json.extract! player, :id, :name, :human, :job, :player_type, :family, :guild, :params, :income, :influence, :player_military_outlays
json.job player.job, partial: "jobs/job", as: :job

influence_items = [
  InfluenceItem.new(
    id: 0,
    value: player.params['influence'],
    comment: 'Ручная правка',
    player: player),
  *player.influence_items
].reverse

json.influence_items influence_items, partial: "influence_items/influence_item", as: :influence_item
json.url player_url(player, format: :json)
