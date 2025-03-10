

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

names = ["Рюриковичи", "Аксаковы", "Патрикеевы", "Волоцкие", "Большие", "Молодые", "Голицыны"]
@families = []
names.each do |name|
  @families.push(Family.create(name: name))
end

job_names = ["Великий князь", "Митрополит", "Посольский дьяк", "Казначей", 
  "Воевода", "Тайный советник", "Княжеский зодчий", 
  "Окольничий", "Дух русского бунта", "Глава гульдии"] #Порядок не трогать!
@jobs = []

job_names.each do |name|
  @jobs.push Job.create(name: name)
end

noble_names = ["Рюрикович", "Геронтий", "Аксаков", "Патрикеев", "Большой", "Молодой", "Волоцкий", "Голицын"] #Порядок не трогать!
buyer_names = ["Марфа", "Шимяка", "Шелом", "Яромила", "Булат", "Богатина", "Алтын", "Любава", "Матрена"]

@nobles = []
@buyers = []

# ОБЯЗАТЕЛЬНЫЙ КУПЕЦ-ГЛАВА ГИЛЬДИИ
Player.create(id: 1, name: "КУПЕЦ", human: @humans.shuffle.first, player_type: @player_types[0], family: @families.shuffle.first, jobs: [@jobs.last], params: {"contraband" => []})

noble_names.each_with_index do |name, i|
  p = Player.create(name: name, human: @humans.shuffle.first, player_type: @player_types[1], jobs: [@jobs[i]], family: @families.shuffle.first, params: {"income_taken" => false})
  @nobles.push 
  InfluenceItem.add(0, "Ручная правка", p)
end

buyer_names.each_with_index do |name, i|
  @buyers.push Player.create(name: name, human: @humans.shuffle.first, player_type: @player_types[0], family: @families.shuffle.first, params: {"contraband" => []})
end


