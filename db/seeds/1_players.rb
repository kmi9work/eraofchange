

human_names = ["Михаил Соколов", "Милана Майорова", "Александр Осипов", "Фёдор Захаров", 
  "Никита Некрасов", "Саша Никифоров", "Марьям Ковалева", "Илья Волков ", "Мирослава Чернова", 
  "Александра Кузьмина", "Павел Самсонов", "Леон Захаров", "Вася Пупкин", "Петя Горшков", 
  "Вова Распутин", "Анна Неболей", "Надя Петрова", "Саша Никифоров"]
@humans = []
human_names.each do |name|
  @humans.push(Human.create(name: name))
end

pt_types = ["Купец","Знать","Мудрец","Дух народного бунта"]
@player_types = []
pt_types.each do |name|
  @player_types.push(PlayerType.create(name: name))
end

#ФАМИЛИИ. НЕ ИСПОЛЬЗУЕТСЯ!
names = ["Рюриковичи", "Аксаковы", "Патрикеевы", "Волоцкие", "Большие", "Молодые", "Голицыны"]
@families = []
names.each do |name|
  @families.push(Family.create(name: name))
end

job_names = ["Великий князь", "Митрополит", "Посольский дьяк", "Казначей", 
  "Воевода", "Тайный советник", "Зодчий", 
  "Окольничий", "Дух русского бунта", "Глава гульдии"] #Порядок не трогать!
@jobs = []

job_names.each_with_index do |name, idx|
  @jobs.push Job.create(id: idx + 1, name: name)
end

noble_names = ["Рюрикович", "Геронтий", "Аксаков", "Патрикеев", "Волоцкий", "Молодой", "Большой", "Голицын", "Дух народного бунта"] #Порядок не трогать!

@nobles = []
@buyers = []

# ОБЯЗАТЕЛЬНЫЙ КУПЕЦ-ГЛАВА ГИЛЬДИИ
merchant_human = @humans.shuffle.first
merchant_family = @families.shuffle.first
merchant_identificator = Player.generate_identificator("КУПЕЦ", merchant_human.name, merchant_family.name, @jobs.last.name)
Player.create(name: "КУПЕЦ", identificator: merchant_identificator, human: merchant_human, player_type: @player_types[0], family: merchant_family, jobs: [@jobs.last], params: {"contraband" => []})

noble_names.each_with_index do |name, i|
  noble_human = @humans.shuffle.first
  noble_family = @families.shuffle.first
  noble_identificator = Player.generate_identificator(name, noble_human.name, noble_family.name, @jobs[i].name, i)
  p = Player.create(name: name, identificator: noble_identificator, human: noble_human, player_type: @player_types[1], jobs: [@jobs[i]], family: noble_family, params: {"income_taken" => false})
  @nobles.push
  InfluenceItem.add(0, "Ручная правка", p)
end

# ==========================================
# ТЕСТОВЫЕ ДАННЫЕ ДЛЯ КУПЦОВ
# ==========================================
# Три гильдии создаются в 5_economics.rb: Забавники (1), Каменщики (2), Пивовары (3)
# Купцы создаются здесь и привязываются к гильдиям после их создания — через after_seeds.
# Чтобы не зависеть от порядка файлов, купцов создадим в отдельном файле.
# Однако since seeds выполняются в порядке файлов (0_, 1_, 2_ ... 5_),
# привязку к гильдиям и создание предприятий делаем в 6_merchants.rb.

# Создаём игроков-купцов с заданными именами и идентификаторами
guild_boss_job = @jobs.last # "Глава гульдии"

merchant_defs = [
  { name: "Забавник",  identificator: "КУПЕЦ-ЗАБАВНИК",  family: "Рюриковичи" },
  { name: "Каменщик",  identificator: "КУПЕЦ-КАМЕНЩИК",  family: "Аксаковы"   },
  { name: "Пивовар",   identificator: "КУПЕЦ-ПИВОВАР",   family: "Голицыны"   },
  { name: "Вольный",   identificator: "КУПЕЦ-ВОЛЬНЫЙ",   family: "Волоцкие"   },
  { name: "Странник",  identificator: "КУПЕЦ-СТРАННИК",  family: "Патрикеевы" },
]

@test_merchants = []
merchant_defs.each do |md|
  human = Human.create(name: md[:name])
  family = Family.find_or_create_by(name: md[:family])
  player = Player.create(
    name:           md[:name],
    identificator:  md[:identificator],
    human:          human,
    player_type:    @player_types[0], # Купец
    family:         family,
    jobs:           [guild_boss_job],
    params:         { "contraband" => [] }
  )
  @test_merchants << player
end






