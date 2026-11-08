json.extract! army, :id, :name, :hidden, :settlement, :owner_id, :owner_type, :attack_power, :defense_power, :params, :created_at, :updated_at

# Положение армии на карте (0..1 от полотна): nil у армии в городе — клиент
# берёт координаты поселения (экран «Карта» в era_native).
json.map_x army.map_x
json.map_y army.map_y

# Шаги перемещения за год (правила заказчика): сколько потрачено и сколько всего
# положено по составу и технологии «Консервирование» государства армии. Правило
# считает сервер (Army#steps_max) — клиент только показывает числа.
json.steps_spent army.steps_spent
json.steps_max army.steps_max

# Государство армии выводится из владельца (Д8): страна-владелец или государство знати
json.country_id army.country_id
json.country army.country && { id: army.country.id, name: army.country.name, short_name: army.country.short_name }

if army.owner_type == 'Player'
  json.owner army.owner, partial: "players/player", as: :player
elsif army.owner_type == 'Country'
  json.owner army.owner, partial: "countries/country", as: :country
end

json.troops army.troops, partial: "troops/troop", as: :troop

json.url army_url(army, format: :json)
