puts "Настройка параметров вассалитета для Vassals and Robbers..."

# Создаем настройки дохода от вассалов
vassalage_settings = GameParameter.find_or_create_by(identificator: "vassalage_settings") do |gp|
  gp.name = "Настройки вассалитета"
  gp.value = "1"
end

# Если запись уже существует, но params нет, добавляем их
vassalage_settings.params ||= {}
vassalage_settings.params['vassal_incomes'] = {
  Country::NOVGOROD => 60000,
  Country::PERMIAN => 20000,
  Country::TVER => 10000,
  Country::RYAZAN => 10000
}
vassalage_settings.save!

puts "Настройки вассалитета созданы/обновлены"

