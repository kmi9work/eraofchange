puts "=== Vassals and Robbers: Обновление технологий ==="

# Удаляем технологии, которые не нужны в новой игре
technologies_to_remove = [
  "Иностранные наёмники",
  "Кузнечное дело",
  "Развитая бюрократия"
]

technologies_to_remove.each do |tech_name|
  tech = Technology.find_by(name: tech_name)
  if tech
    puts "Удаляем технологию: #{tech_name}"
    # Удаляем связанные TechnologyItem
    tech.technology_items.destroy_all
    # Удаляем саму технологию
    tech.destroy
  else
    puts "Технология '#{tech_name}' не найдена"
  end
end

# Обновляем описание "Москва — Третий Рим"
moscow_tech = Technology.find_by(name: "Москва — Третий Рим")
if moscow_tech
  old_description = moscow_tech.description
  new_description = old_description.gsub('+2', '+1')
  moscow_tech.update(description: new_description)
  puts "Обновлена технология 'Москва — Третий Рим': '#{old_description}' → '#{new_description}'"
else
  puts "Технология 'Москва — Третий Рим' не найдена"
end

puts "=== Технологии обновлены для игры Vassals and Robbers ==="

