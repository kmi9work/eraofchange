# Названия технологий в модуле many_teams.
#
# Технология 6 в ядре называется «Москва — Третий Рим» (db/seeds/technologies.csv).
# В игре за любое государство «Москва» в названии неверна: бонус начисляется паре
# с «Русью» и действует у всех русских земель (Country#third_rome_bonus_for?),
# а не только у Москвы. Поэтому в модуле технология называется «Третий Рим».
# Код адресует её константой Technology::MOSCOW_THIRD_ROME, id не меняется —
# правится только name, поэтому открытие технологии и её эффект не затронуты.
puts "[many_teams] названия технологий"

third_rome_name = "Третий Рим"
third_rome = Technology.find_by(id: Technology::MOSCOW_THIRD_ROME)

if third_rome.nil?
  puts "  ! технология id=#{Technology::MOSCOW_THIRD_ROME} не найдена — пропущено"
elsif third_rome.name == third_rome_name
  puts "  технология #{Technology::MOSCOW_THIRD_ROME} уже называется «#{third_rome_name}»"
else
  old_name = third_rome.name
  third_rome.update!(name: third_rome_name)
  puts "  технология #{Technology::MOSCOW_THIRD_ROME}: «#{old_name}» → «#{third_rome_name}»"
end
