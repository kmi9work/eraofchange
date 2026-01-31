

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
Player.create(id: 1, name: "КУПЕЦ", identificator: merchant_identificator, human: merchant_human, player_type: @player_types[0], family: merchant_family, jobs: [@jobs.last], params: {"contraband" => []})

ActiveRecord::Base.connection.reset_pk_sequence!('players')

noble_names.each_with_index do |name, i|
  noble_human = @humans.shuffle.first
  noble_family = @families.shuffle.first
  noble_identificator = Player.generate_identificator(name, noble_human.name, noble_family.name, @jobs[i].name, i)
  p = Player.create(name: name, identificator: noble_identificator, human: noble_human, player_type: @player_types[1], jobs: [@jobs[i]], family: noble_family, params: {"income_taken" => false})
  @nobles.push 
  InfluenceItem.add(0, "Ручная правка", p)
end







