
region = Region.find_by_name("Вологодская земля")
PublicOrderItem.add(-6, "Начальные условия", region)

p = Player.find_by_name("Геронтий")
InfluenceItem.add(0, "Ручная правка", p)

s = Settlement.find_by_name("Белоозеро")
s.player = p
s.save

s = Settlement.find_by_name("Нижний новгород")
s.player = Player.find_by_name("Большой")
s.save

a = Army.find_by_name("Новгород 1")
a = 