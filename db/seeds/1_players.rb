

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
  "Воевода", "Тайный советник", "Зодчий", 
  "Окольничий", "Дух русского бунта", "Глава гульдии"]
@jobs = []

job_names.each do |name|
  @jobs.push Job.create(name: name)
end

noble_names = ["Иван III", "Борис", "Манюня", "Распутин", "Геронтий", "Образина", "Распутин", "Хренов", "Даниил"]
buyer_names = ["Марфа", "Шимяка", "Шелом", "Яромила", "Булат", "Богатина", "Алтын", "Любава", "Матрена"]

@nobles = []
@buyers = []

noble_names.each_with_index do |name, i|
  @nobles.push Player.create(name: name, human: @humans.shuffle.first, player_type: @player_types[1], job: @jobs[i], family: @families.shuffle.first, params: {"influence" => rand(5), "contraband" => []})
end

buyer_names.each_with_index do |name, i|
  @buyers.push Player.create(name: name, human: @humans.shuffle.first, player_type: @player_types[0], family: @families.shuffle.first, params: {"influence" => rand(5), "contraband" => []})
end

