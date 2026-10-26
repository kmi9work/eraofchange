# Каталог политдействий движка many_teams (п. 5, 10, 11).
#
# Сиды идемпотентны: типы ищутся по значению колонки action и обновляются,
# а не создаются заново — повторный db:seed:many_teams не плодит дубли.
puts "[many_teams] политические действия"

def upsert_action_type(job_name, action, attributes)
  job = Job.find_by(name: job_name)
  if job.nil?
    puts "  ! должность «#{job_name}» не найдена — «#{action}» пропущено"
    return nil
  end

  type = PoliticalActionType.find_or_initialize_by(action: action)
  type.job = job
  attributes.each { |key, value| type.public_send("#{key}=", value) }
  type.save!
  puts "  #{job_name}: #{type.name} (#{action})"
  type
end

# ---- п. 2 заказчика: Казначей разрешает/запрещает гильдии строительство и работу ----
upsert_action_type("Казначей", "set_guild_permission",
  icon: "ri-toggle-line",
  name: "Разрешить/запретить строительство и работу предприятий гильдии",
  description: "Казначей разрешает или запрещает выбранной гильдии строить предприятия и работать " \
               "на уже построенных в своём государстве. Запрет один: он закрывает и строительство, " \
               "и работу. Действие выполняется сразу, без броска: это распоряжение по казне.",
  cost: "",
  probability: "—",
  success: "Разрешение гильдии на строительство и работу в государстве изменено.",
  failure: "—")

# ---- п. 10: Великий князь снимает все эмбарго с гильдии (технология «Заморская торговля») ----
# Технология — условие правил, а не блокировка (решение заказчика): без неё
# действие выполняется, но клиент предупреждает, что оно запрещено.
upsert_action_type("Великий князь", "lift_guild_embargoes",
  icon: "ri-lock-unlock-line",
  name: "Снять все эмбарго с гильдии",
  description: "По технологии «Заморская торговля» Великий князь добивается снятия всех эмбарго, " \
               "наложенных на выбранную гильдию любыми государствами. Без открытой технологии " \
               "действие запрещено правилами — экран показывает предупреждение.",
  cost: "",
  probability: "—",
  success: "Все эмбарго с гильдии сняты.",
  failure: "—")

# ---- п. 11: у Тайного советника другие действия ----
removed = PoliticalActionType.where(action: %w[fabricate_a_denunciation favoritism counterintelligence])
puts "  Тайный советник: убрано старых действий #{removed.count}"
removed.destroy_all

upsert_action_type("Тайный советник", "conduct_intelligence",
  icon: "ri-spy-line",
  name: "Разведка",
  description: "Тайный советник добывает сведения о команде-сопернике. Пункты разведки: " \
               "общественный порядок в регионе (1000), отношения соперника с державой (1000), " \
               "доход знати соперника (3000), открытые технологии соперника (3000).",
  cost: "1000–3000 (по пункту разведки)",
  probability: "—",
  success: "Сведения получены и записаны в отчёт.",
  failure: "—")

upsert_action_type("Тайный советник", "undermine_stability",
  icon: "ri-flashlight-line",
  name: "Подорвать стабильность в регионе",
  description: "Агенты Тайного советника раскачивают обстановку в выбранном регионе.",
  cost: "10000",
  probability: "—",
  success: "Общественный порядок в регионе падает на 3 пункта.",
  failure: "—")

upsert_action_type("Тайный советник", "undermine_relations",
  icon: "ri-dislike-line",
  name: "Подорвать отношения двух стран",
  description: "Тайный советник ссорит две державы. По умолчанию первая страна — зарубежная, " \
               "вторая — текущая.",
  cost: "10000",
  probability: "—",
  success: "Отношения пары ухудшаются на 1 пункт.",
  failure: "—")
