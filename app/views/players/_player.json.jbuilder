json.extract! player, :id, :name, :identificator, :guild_id, :family_id, :human, :own_count, :my_buildings, :player_type, :family, :guild, :params, :income, :influence, :player_military_outlays

json.owner_type 'Player'
json.jobs player.jobs do |job|
  json.id job.id
  json.name job.name
  json.player_ids job.player_ids
end 

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
