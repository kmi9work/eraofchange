# Крепость в «Вассалах и разбойниках» имеет ОДИН уровень: «Форт».
#
# Ядро (db/seeds/2_politics.rb) заводит три уровня «Кремля» и ставит городам
# уровень из countries.csv — в этой игре так нельзя: улучшать крепость некуда
# (запрет в VassalsAndRobbers::Concerns::BuildingExtensions), а на карте
# планшета мастеров крепость рисуется одним цветом и одним правилом «нужна
# пушка».
#
# Сид идемпотентен: всех форты переводятся на уровень 1, лишние уровни
# справочника удаляются. Повторный прогон печатает нули.
def_build = BuildingType.find_by(name: "Кремль") || BuildingType.find(BuildingType::DEFENCE)
raise "[vassals] не найден тип постройки «Кремль»" unless def_build

first_level = BuildingLevel.find_by(level: BuildingLevel::FIRST_LEVEL, building_type_id: def_build.id)
raise "[vassals] не найден первый уровень крепости («Форт»)" unless first_level

downgraded = 0
Building.joins(:building_level)
        .where(building_levels: { building_type_id: def_build.id })
        .find_each do |building|
  next if building.building_level_id == first_level.id

  building.update!(building_level: first_level)
  downgraded += 1
end

extra_levels = BuildingLevel.where(building_type_id: def_build.id)
                            .where("level > ?", first_level.level)
removed_levels = extra_levels.count
extra_levels.destroy_all

puts "[vassals] крепости: переведено на 1-й уровень — #{downgraded}, удалено уровней справочника — #{removed_levels}"
