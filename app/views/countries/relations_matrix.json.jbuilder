# Таблица отношений для раздела «Дашборд» (ТЗ № 2, § 2.3).
# Строка = пара (A, B): A — выбранное государство («страна, за которую мастерим»),
# B — любая другая страна. Все правки и кнопки строки действуют в контексте A
# (партиал отдаёт B с данными пары, партнёр — A).
json.country_ids @countries.map(&:id)

json.countries @countries do |country|
  json.extract! country, :id, :name, :short_name, :flag_image_name
end

json.rows @rows do |row|
  json.partner do
    json.extract! row[:a], :id, :name, :short_name, :flag_image_name
  end

  # Полное представление страны B с отношениями пары (A ↔ B), как в /countries.json
  json.country do
    json.partial! "countries/country", country: row[:b], partner_country: row[:a]
  end
end
