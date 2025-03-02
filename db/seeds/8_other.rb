Player.where("id > #{Player.count / 2}").update_all(guild_id: Guild.first.id)
Player.where("id <= #{Player.count / 2}").update_all(guild_id: Guild.first(2).last.id)

