# Игрок в разрезе государства (@players_country — государство запроса, иначе текущее):
# доход и влияние считаются по владениям этого государства (Д7).
country = @players_country || Country.current

json.extract! player, :id, :name, :identificator, :guild_id, :family_id, :human, :own_count, :my_buildings, :player_type, :family, :guild, :params, :player_military_outlays
json.country_id player.country_id
json.country player.country && { id: player.country.id, name: player.country.name, short_name: player.country.short_name, flag_image_name: player.country.flag_image_name }
json.income player.income(country)
json.influence player.influence(country)

json.owner_type 'Player'
json.jobs player.jobs do |job|
  json.id job.id
  json.name job.name
  json.player_ids job.player_ids
end 

influence_items = [
  InfluenceItem.new(
    id: 0,
    value: player.influence_buildings(country),
    comment: 'Влияние от зданий',
    player: player
  ),
  *player.influence_items
]

json.influence_items influence_items.reverse, partial: "influence_items/influence_item", as: :influence_item
json.url player_url(player, format: :json)
