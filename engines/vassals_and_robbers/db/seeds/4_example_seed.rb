# EXAMPLE: Это шаблонный файл для создания своего Engine
# Пример seed файла для vassals_and_robbers Engine

# TODO: Добавьте начальные данные для вашей игры
# Например:
# VassalsAndRobbers::Vassal.create(name: "Вассал 1", loyalty: 80)
# VassalsAndRobbers::Robber.create(name: "Разбойник 1", danger_level: 5)

require 'securerandom'

puts "Загрузка seeds для Vassals and Robbers..."

SEED_TAG = 'vassals_and_robbers_processing_seed'.freeze
TARGET_PLANT_COUNT = 15

existing_seed_plants = Plant.where("params ->> 'seed_tag' = ?", SEED_TAG)
remaining_to_create = TARGET_PLANT_COUNT - existing_seed_plants.count

if remaining_to_create <= 0
  puts "Перерабатывающие предприятия этого сида уже созданы (#{existing_seed_plants.count})."
else
  processing_levels = PlantLevel
                      .joins(:plant_type)
                      .where(plant_types: { plant_category_id: PlantCategory::PROCESSING })

  if processing_levels.empty?
    puts 'Перерабатывающие уровни предприятий не найдены. Создание пропущено.'
  else
    guilds = Guild.all.to_a

    if guilds.empty?
      puts 'Гильдии не найдены. Создание перерабатывающих предприятий невозможно.'
    else
      level_iterator = processing_levels.shuffle.cycle
      selected_guilds = guilds.shuffle.cycle.take(remaining_to_create)

      Plant.transaction do
        selected_guilds.each_with_index do |guild, index|
          next_level = level_iterator.next

          Plant.create!(
            plant_level: next_level,
            economic_subject: guild,
            comments: "Создано сидом Vassals and Robbers ##{existing_seed_plants.count + index + 1}",
            params: {
              'produced' => [],
              'seed_tag' => SEED_TAG,
              'seed_index' => existing_seed_plants.count + index + 1
            }
          )
        end
      end

      puts "Создано #{remaining_to_create} перерабатывающих предприятий для различных гильдий."
    end
  end
end

