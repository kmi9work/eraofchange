# Seeds для создания гильдий и предприятий согласно дампу
# Используется только в игре vassals-and-robbers

puts "[Vassals and Robbers] Creating guilds and plants..."

# Создание/обновление гильдий
guilds_data = [
  [1, "Зелёные"],
  [2, "Жёлтые"],
  [3, "Синие"],
  [4, "Красные"]
]

guilds_data.each do |id, name|
  guild = Guild.find_or_initialize_by(id: id)
  guild.name = name
  guild.save!
  puts "  ✓ Guild #{id}: #{name}"
end

# Создание/обновление предприятий
plants_data = [
  [3, 7, 29, 1, "Guild"],
  [4, 1, 29, 1, "Guild"],
  [5, 1, 27, 1, "Guild"],
  [6, 7, 28, 1, "Guild"],
  [7, 10, 29, 1, "Guild"],
  [8, 1, 30, 2, "Guild"],
  [9, 10, 27, 2, "Guild"],
  [10, 10, 28, 2, "Guild"],
  [11, 7, 30, 2, "Guild"],
  [12, 7, 27, 2, "Guild"],
  [13, 1, 27, 3, "Guild"],
  [14, 1, 28, 3, "Guild"],
  [15, 7, 29, 3, "Guild"],
  [16, 10, 30, 3, "Guild"],
  [17, 10, 27, 3, "Guild"],
  [18, 1, 27, 4, "Guild"],
  [19, 7, 28, 4, "Guild"],
  [20, 1, 29, 4, "Guild"],
  [21, 7, 27, 4, "Guild"],
  [22, 10, 29, 4, "Guild"]
]

plants_data.each do |id, plant_level_id, plant_place_id, economic_subject_id, economic_subject_type|
  # Проверяем, что гильдия существует
  unless Guild.exists?(economic_subject_id)
    puts "  ⚠ Warning: Guild #{economic_subject_id} does not exist for Plant #{id}, skipping..."
    next
  end

  # Проверяем, что plant_level существует
  unless PlantLevel.exists?(plant_level_id)
    puts "  ⚠ Warning: PlantLevel #{plant_level_id} does not exist for Plant #{id}, skipping..."
    next
  end

  # Проверяем, что plant_place существует
  unless PlantPlace.exists?(plant_place_id)
    puts "  ⚠ Warning: PlantPlace #{plant_place_id} does not exist for Plant #{id}, skipping..."
    next
  end

  # Находим или создаем предприятие с указанным id
  plant = Plant.find_or_initialize_by(id: id)
  was_new = plant.new_record?
  
  # Обновляем все параметры предприятия
  plant.plant_level_id = plant_level_id
  plant.plant_place_id = plant_place_id
  plant.economic_subject_id = economic_subject_id
  plant.economic_subject_type = economic_subject_type
  plant.params ||= {"produced" => []}
  
  if plant.save
    status = was_new ? "created" : "updated"
    puts "  ✓ Plant #{id} #{status}: level=#{plant_level_id}, place=#{plant_place_id}, owner=Guild #{economic_subject_id}"
  else
    puts "  ✗ Plant #{id} failed to save: #{plant.errors.full_messages.join(', ')}"
  end
end

puts "[Vassals and Robbers] Guilds and plants created successfully!"

ActiveRecord::Base.connection.reset_pk_sequence!('guilds')
ActiveRecord::Base.connection.reset_pk_sequence!('plants')