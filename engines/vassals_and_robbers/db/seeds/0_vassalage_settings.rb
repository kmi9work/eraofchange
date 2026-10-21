puts "Настройка параметров вассалитета для Vassals and Robbers..."

# Создаем настройки дохода от вассалов
vassalage_settings = GameParameter.find_or_create_by(identificator: "vassalage_settings") do |gp|
  gp.name = "Настройки вассалитета"
  gp.value = "1"
end

# Доходы вассалов — по сюзеренам: { "<сюзерен>" => { "<вассал>" => доход } } (Д14.1).
# Плоский формат (до перехода) относился к «Руси» и переносится её ключом.
vassalage_settings.params ||= {}
vassalage_settings.params['vassal_incomes'] = VassalsAndRobbers::VassalageSettings.store_incomes(
  vassalage_settings.params['vassal_incomes'],
  Country.rus_country,
  {
    Country::NOVGOROD => 60000,
    Country::PERMIAN => 30000,
    Country::TVER => 20000,
    Country::RYAZAN => 20000
  }
)
vassalage_settings.save!

puts "Настройки вассалитета созданы/обновлены"

