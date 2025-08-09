Player.where("id > #{Player.count / 2}").update_all(guild_id: Guild.first.id)
Player.where("id <= #{Player.count / 2}").update_all(guild_id: Guild.first(2).last.id)

InfluenceItem.add(-6, "Начальные условия", Player.find_by_name('Геронтий'), nil)
InfluenceItem.add(-1, "Начальные условия", Player.find_by_name('Рюрикович'), nil)
InfluenceItem.add(-1, "Начальные условия", Player.find_by_name('Волоцкий'), nil)
