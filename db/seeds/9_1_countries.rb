# Привязка данных seeds к государствам (ТЗ «несколько команд», § 10 п. 2).
#
# Зачем файл: раздельные данные создаются для всех государств сразу, а признаки
# «играбельное государство» нет — значит, любая запись без страны должна получить
# свою страну на этапе сидирования. Знать и купцы создаются в 1_players.rb,
# гильдии — в 5_economics.rb, технологии — в 2_politics.rb (там же country_id);
# этот файл идемпотентно дочищает всё, что осталось без страны (например, записи,
# созданные движками), относя их к «Руси».
#
# ВАЖНО (отличие от ТЗ). В ТЗ файл назван `1_1_countries.rb`, но seeds грузятся
# по алфавиту (`lib/tasks/custom_seed.rake:28`, `Dir[...].sort`), а строка
# `1_1_countries.rb` сортируется РАНЬШЕ `1_players.rb` — на тот момент ни игроков,
# ни гильдий, ни государств (они создаются в 2_politics.rb из countries.csv) ещё нет,
# и привязывать было бы нечего. Поэтому файл назван `9_1_countries.rb`: он выполняется
# после 5_economics.rb и 8_other.rb, когда все справочники и данные уже созданы,
# и запускается повторно без дублей (обновляются только строки с country_id IS NULL).
#
# Повторный `db:seed:all` без пересоздания базы ничего не ломает: find_or_create_by
# в основных seed-файлах и обновление только «пустых» строк здесь.

rus = Country.find_by(id: Country::RUS) || Country.order(:id).first

if rus.nil?
  puts "Привязка к государствам пропущена: в базе нет ни одного государства"
else
  bound = {}

  # Знать, купцы и прочие игроки
  bound[:players] = Player.where(country_id: nil).update_all(country_id: rus.id)

  # Гильдии купцов (создаются в 5_economics.rb с country_id; здесь — страховка)
  bound[:guilds] = Guild.where(country_id: nil).update_all(country_id: rus.id)

  # Факт открытия технологии — на пару «технология × государство»
  bound[:technology_items] = TechnologyItem.where(country_id: nil).update_all(country_id: rus.id)

  # Политические действия
  bound[:political_actions] = PoliticalAction.where(country_id: nil).update_all(country_id: rus.id)

  puts "Привязка к «#{rus.name}» выполнена: " +
       bound.map { |model, count| "#{model}=#{count}" }.join(', ')
end
