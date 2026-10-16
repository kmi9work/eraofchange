# ТЗ № 1. Этап 1: структура данных для режима «несколько команд»

Паспорт документа

| Поле | Значение |
|---|---|
| Версия | 1.0 (на согласование) |
| Дата | 2026-10-16 |
| Ветка | `many_teams` в `eraofchange` и `era_front` |
| Область этапа | `eraofchange`: схема БД, миграции, модели, JSON-контракт API, seeds, rake-задачи. `era_front`: только контракт API (изменения экранов — этап 2) |
| Связанный документ | ТЗ № 2 «Функциональность»: `docs/many_teams/TZ-2-funkcionalnost.md` |
| Источник требований | Постановка заказчика от 2026-10-16 (разделы «Дашборд», «Информация о стране», «Политика», «Сражения») |
| Критерий готовности этапа | Один и тот же код работает в режиме one-team (как сейчас, только «Русь») и many-teams (несколько играбельных государств); на существующей базе после миграций поведение не меняется; на новой игре данные государств разделены |

---

## 1. Контекст: что есть сейчас

Программа обслуживает одно государство. «Русь» жёстко зашита константой `Country::RUS = 1` (`eraofchange/app/models/country.rb:22`) и используется в 29 местах бэкенда (полный инвентарь — приложение А).

Фактическое состояние ключевых сущностей:

| Сущность | Как хранится сейчас | Где |
|---|---|---|
| Государства | `countries` (id, name, short_name, flag_image_name, params). Признака «играбельная» нет | `db/schema.rb:151-158` |
| Игроки | `players` без привязки к государству; `human_id`, `player_type_id`, `family_id`, `guild_id`, `params` | `db/schema.rb:312-324` |
| Знатный совет | Глобальные 10 должностей (`jobs`, id 1..10) + join-таблица `jobs_players` | `db/seeds/1_players.rb:26-31`, `db/schema.rb:237-247` |
| Технологии | Номенклатура `technologies` (12 шт.) + по **одной** строке `technology_items` на технологию (флаг открытия — общий) | `db/seeds/2_politics.rb:146-152`, `app/models/technology.rb:17-35` |
| Отношения | `relation_items` (country_id, value, comment, year, entity): одна величина «страна → Русь», второй конец пары не хранится | `db/schema.rb:378-387`, `app/models/country.rb:294-356` |
| Влияние | `influence_items.player_id` — **уже на игроке**, не на должности | `db/schema.rb:226-235` |
| Доход | `income_items.player_id` + флаг `players.params['income_taken']` — **уже на игроке** | `db/schema.rb:215-224`, `app/models/player.rb:288-401` |
| Политические действия | `political_actions` (player_id, job_id, political_action_type_id, year, success, guild_id) — государства нет; «выполнено» проверяется по `job + year` | `db/schema.rb:341-355`, `era_front/src/views/pages/politics/PoliticalActions.vue:64-70` |
| Владения | `regions.country_id` есть; `settlements` наследуют страну через регион | `db/schema.rb:368-376`, `:426-434` |
| Армии | `armies.owner_type` ∈ {`Player`,`Country`} + `owner_id`; страна армии нигде не зафиксирована | `db/schema.rb:32-43`, `era_front/src/views/pages/politics/Armies.vue:7-14` |
| Сессия | `session[:user_id]` (мастер, `app/controllers/application_controller.rb:13-21`), `session[:player_id]` (игрок, `app/controllers/auth_controller.rb:17-18`) | — |

Вывод: нужны три вещи — (1) явный признак играбельного государства и «текущее государство» вместо `Country::RUS`, (2) привязка игрока к государству как опорная связь для совета, влияния, дохода и армий, (3) перевод трёх «одногосударственных» сущностей (технологии, отношения, политдействия) в разрез по государству.

---

## 2. Границы этапа

Входит:

- миграции схемы;
- ассоциации, скоупы, методы и валидации моделей;
- изменения форматов JSON-параметров (`countries.params`, `GameParameter.params`);
- контракт API: новые поля и параметры запросов (без изменений UI);
- seeds: список команд, создание раздельных данных;
- rake-задача запуска игры для one-team / many-teams;
- миграция существующих данных, обратная совместимость, тест-план данных.

Не входит (отдельные этапы, согласуются отдельно):

- эффекты технологий (что именно даёт открытая технология) — прямо исключено заказчиком;
- эффекты политических действий — прямо исключено заказчиком;
- экономика: предприятия, рынок, караваны, товарооборот как отдельный экран;
- движки `vassals_and_robbers` и `artel` (они Русь-центричны: `engines/vassals_and_robbers/app/services/vassals_and_robbers/checklist_validator.rb:69`, `engines/artel/app/controllers/concerns/plant_places_controller_extensions.rb:15`);
- расходы государства (`GameParameter#pay_state_expenses`), годовые результаты игры;
- мобильные приложения `era_native`, `era_players`;
- интерфейс `era_front` — этап 2.

---

## 3. Термины

| Термин | Значение |
|---|---|
| Играбельное государство | Государство, за которое играет команда мастеров; признак `countries.playable` |
| Текущее государство | Государство, выбранное мастером; источник всех «моих» данных в API; замена `Country::RUS` |
| Режим one-team | `many_teams.enabled = false`. Играбельно только «Русь», текущее государство всегда «Русь». Поведение полностью как до доработки |
| Режим many-teams | `many_teams.enabled = true`. Играбельных государств несколько |
| Совет государства | Игроки типа «Знать» (`player_type_id = 2`) этого государства в разрезе должностей |
| Пара отношений | Два государства A и B, между которыми считается одна величина отношений |
| Команда | Мастера, работающие за одно играбельное государство (не сущность БД; соответствует играбельному государству) |

---

## 4. Режим работы: переключатель

Вводится `GameParameter` с `identificator = 'many_teams'` и `params`:

```json
{ "enabled": false }
```

- Единственный источник режима. Список играбельных государств — колонка `countries.playable` (не дублируется в params, чтобы не было двух правд).
- Значения по умолчанию сидируются в `db/seeds/0_game_parameters.rb` (`enabled = false`), флаг `playable` — для «Руси» в `db/seeds/2_politics.rb` (создание стран из `countries.csv`).
- Хелперы: `GameParameter.many_teams_enabled?` → boolean, `Country.playable` → scope.
- В режиме one-team: `Country.current` принудительно = «Русь»; параметры API, относящиеся к выбору государства, игнорируются (подставляется «Русь»).
- Переключатель в интерфейсе — «Служебное → Настройки» (этап 2, § 6.5 ТЗ № 2).

Обоснование выбора `GameParameter`: все настройки игры живут в `GameParameter` (`identificator` + JSON `params`), это же место, откуда их читает фронт и откуда они попадают в seeds. База при старте игры пересоздаётся (`rake game:core` = `db:drop` + `db:migrate` + `db:seed:all`, `eraofchange/lib/tasks/custom_seed.rake:44-56`), поэтому «правда» о режиме обязана быть в seeds, а не только в БД.

---

## 5. Ключевые проектные решения

### Д1. Текущее государство — в сессии, по образцу выбора мастера

Решение: `session[:country_id]` + реестр страны в запросе через класс-аксессор `Country.current` / `Country.current=` (по образцу `Player.current`, `app/models/player.rb:45-60`) и `before_action :set_current_country` в `ApplicationController` рядом с `set_current_player` (`app/controllers/application_controller.rb:28-33`).

Правило разрешения `Country.current`:

1. `session[:country_id]`, если он задан и страна существует;
2. иначе `Country::RUS` (режим one-team, обратная совместимость);
3. в режиме one-team `session[:country_id]` игнорируется, всегда `RUS`.

Требование заказчика: «этот выбор сохраняется в сессию так же, как сохраняется user» — сохраняем именно в сессию, новых колонок в `users` не вводим. Опционально (не входит в обязательный объём) в `users` можно добавить `default_country_id` как «государство мастера по умолчанию» — см. открытый вопрос Q5.

### Д2. Игрок привязан к государству

`players.country_id` — опорная связь всей модели. Через неё выводятся: совет государства, доход и влияние «по текущему государству», страна армий, принадлежащих знати.

Правило: `Player#country` не может быть пустым. Реализуется `belongs_to :country, optional: true` + `before_validation :assign_default_country` (значение по умолчанию — `Country.current || Country.find(Country::RUS)`), чтобы старый код и движки, создающие игроков без страны, не падали и продолжали работать в one-team режиме.

### Д3. Знатный совет: без дублирования строк `jobs`

Решение (вариант A, рекомендуется): должности `jobs` остаются единым справочником 10 записей с неизменными id (на них завязаны константы `Job::GRAND_PRINCE = 1` … `Job::GUILD_BOSS = 10`, `app/models/job.rb:14-23`). «Свой совет в каждом государстве» получается так: совет государства = `players.where(country_id: <государство>)` в разрезе `jobs_players`. То есть у каждого государства свои люди на тех же должностях — должности «дублируются» по составу, а не по строкам справочника.

Технически: `Country#council(job)` / `Country#council_players(job_id)`, `Country#council_jobs` (упорядоченный список должностей с занятыми из этого государства).

Отклонённые альтернативы:

- вариант B — `jobs.country_id` и копия 10 должностей на государство: ломает константы-id (придётся вводить `kind` и переписать ~15 вызовов `Job.find_by_id(Job::X)` — приложение А), а вместе с должностями придётся дублировать и `political_action_types` (они `belongs_to :job`, `app/models/political_action_type.rb:6-8`, наполняются из `pat_nobles.csv`/`pat_merchants.csv`, `db/seeds/2_politics.rb:118-141`) — это N×дублирование справочника действий и копии эффектов;
- вариант C — отдельная таблица `countries_jobs` (страна + должность + игрок): по сути то же, что вариант A, но с лишней таблицей, дублирующей `jobs_players` + `players.country_id`.

Вариант A требует минимальных правок: единственное реальное изменение — везде, где код берёт «игроков должности» (`Job.find_by_id(...).players`), брать их через государство (см. § 8.3 и ТЗ № 2 § 2).

### Д4. Отношения становятся парными

`relation_items.partner_country_id` — второй конец пары. Значение отношений пары (A,B) = сумма значений всех `relation_items`, где (country_id = A и partner_country_id = B) **или** (country_id = B и partner_country_id = A), с кэпом ±`Country::REL_RANGE` (±2).

Почему так: мастера обоих государств могут править одну и ту же пару со своей стороны, а величина остаётся одна на пару (как в игре «отношения России и Литвы» — одна шкала). Направленных отношений постановка не требует.

Обратная совместимость: при миграции все существующие строки получают `partner_country_id = Country::RUS` (1), что в точности воспроизводит нынешнюю семантику «страна → Русь». Строки, где `country_id == partner_country_id` (самопара), всеми читателями игнорируются; такие строки в базе могут существовать (ручные правки по «Руси»), их список выводится отдельным отчётом для ручной разборки.

Бонус технологии «Москва — Третий Рим» (`Country#relations`, `app/models/country.rb:351-356`) сохраняется как бонус **пары с «Русью»**: начисляется, если один конец пары — `RUS`, а второй — одно из {Пермь, Вятка, Рязань, Тверь, Новгород}. В one-team режиме расчёт не меняется.

### Д5. Технологии: номенклатура общая, факт открытия — на государство

`technology_items.country_id` + уникальный индекс `(technology_id, country_id)`. Номенклатура (`technologies`) и описания не меняются. Методы становятся контекстными:

- `Technology#item_for(country)`, `Technology#is_open(country = Country.current)`, `#open_it(country = Country.current)`, `#close_it(country = Country.current)`.

Важно: **эффекты** технологий (что даёт `is_open == 1`, например `player.rb:316` «Юрьев день», `region.rb:36` «Помазанник божий», `plant_level.rb:10` «Технические училища») на этом этапе не пересматриваются. Так как у методов появляется дефолт `Country.current`, все существующие вызовы эффектов продолжают читать статус текущего государства — в one-team режиме это ровно «Русь», как сейчас.

### Д6. Влияние и доход остаются на игроке (фиксация контракта, схемных изменений нет)

- Влияние: `influence_items.player_id`. «Привязано к игроку, а не к должности» — уже так; на этом этапе фиксируем правило и убираем единственный способ «повесить» влияние на должность: выдачи влияния по должности (`Job.find_by_id(Job::X).players`, приложение А, п. 4) должны резолвиться в игроков текущего государства, а не в «глобальных» держателей должности.
- Доход: `income_items.player_id` + `players.params['income_taken']`. Флаг получения дохода живёт на игроке, должностей не касается. Схема не меняется; меняется источник сумм — см. § 8.2.

### Д7. Доход считается только от владений текущего государства (без схемных изменений)

Требование 6: «доходы должны показываться от владений текущей страны, принадлежащих текущим игрокам». Владение игрока — поселение (`settlements.player_id`), а страна определяется регионом (`settlements.region_id → regions.country_id`). Значит достаточно скоупа, новых колонок не нужно:

- `Player#income_breakdown(country = Country.current)` — только поселения игрока, у которых регион принадлежит указанному государству;
- `Player#income(country = Country.current)`, `Player#income_base(country = Country.current)`, `Player#influence(country = Country.current)`;
- надбавки «по должности» (`Государь` → торговая надбавка, `Митрополит` → доход от церквей, `app/models/player.rb:296-318, 355-372`) ищут должность **в совете текущего государства** и церкви — в регионах текущего государства (сейчас жёстко `regions.country_id = Country::RUS`, `app/models/player.rb:311, 367, 424, 434`).

### Д8. Принадлежность армии выводится из владельца, новой колонки нет

- Владелец — `Country` → армия принадлежит этой стране;
- владелец — `Player` типа «Знать» → армия принадлежит `player.country_id`.

Новая колонка `armies.country_id` не вводится: она дублировала бы вывод и устаревала при смене владельца или переводе игрока в другое государство. Вместо этого:

- `Army#country` (по правилу выше), `Army#country_id`;
- скоупы `Army.for_country(c)` (включая армии знати этого государства) и `Army.foreign_to(c)`;
- валидации: `owner_type` ∈ {`Player`,`Country`}; если `owner_type == 'Player'`, то `owner.player_type_id == 2` («Знать»). Сейчас ограничение держится только интерфейсом (`era_front/src/views/pages/politics/Armies.vue:64-70`), в БД его нет.

Если по эксплуатации понадобится быстрая выборка без JOIN — колонка-кэш добавляется отдельным решением (в этом ТЗ не вводится).

### Д9. Политические действия — в разрезе государства

`political_actions.country_id` (индекс). Заполняется при создании из текущего государства. Проверка «действие уже выполнено в этом году» (сейчас по `job + year`, `era_front/src/views/pages/politics/PoliticalActions.vue:64-70`) становится проверкой по `(job, year, country_id)`.

Каталог типов действий (`political_action_types`) не меняется: он остаётся общим, у действий сохраняется `job_id` (справочник должностей общий, см. Д3). Эффекты действий не трогаем.

### Д10. Торговые очки и товарооборот — на пару государств

Сейчас `countries.params['relation_points']` и `['last_trade_turnover']` — скаляры на страну (начисляются от торговли, тратятся на улучшение отношений с этой страной; кнопка «улучшить через торговлю» — `era_front/src/views/dashboard/Relations.vue:150-300`, логика начисления — `app/models/country.rb:184-290`).

В many-teams режиме эти величины относятся к паре (кто торгует ↔ с кем), поэтому формат меняется на хэш по `partner_country_id`:

```json
"relation_points":     { "1": 2 },
"last_trade_turnover": { "1": 45000 }
```

Бэкфилл: существующий скаляр переносится в ключ `"1"` («Русь»). Чтение/запись — методы `Country#relation_points_for(partner)`, `#add_relation_points(partner, n)`, `#last_trade_turnover_for(partner)`, `#set_last_trade_turnover(partner, v)`; прямой доступ к `params['relation_points']` в коде и на фронте убирается.

Зависимость: корректно определить, **чьи** караваны считаются в паре, можно только зная государство гильдии → `guilds.country_id` (Д11) либо, если Д11 не делаем, очки считаются «текущее государство ↔ партнёр» и участвуют только караваны гильдий «Руси». Решение — открытый вопрос Q3.

### Д11. Государство у гильдии (зависимость Д10)

`guilds.country_id` (nullable, бэкфилл = «Русь»). Нужна только для корректного начисления торговых очков по паре в many-teams режиме и для будущего разделения экономики по командам. Экран экономики на этом этапе не меняется, поведение one-team не меняется.

---

## 6. Изменения схемы БД

Порядок миграций и состав:

| № | Имя миграции | Таблица | Изменение | Null | Индекс | Бэкфилл |
|---|---|---|---|---|---|---|
| 1 | `add_playable_to_countries` | `countries` | `playable` (boolean), default `false`, null `false` | нет | — | `playable = true` для `id = 1` |
| 2 | `add_country_to_players` | `players` | `country_id` (integer) | да | `players(country_id)` | `country_id = 1` |
| 3 | `add_country_to_guilds` | `guilds` | `country_id` (integer) | да | `guilds(country_id)` | `country_id = 1` |
| 4 | `add_partner_country_to_relation_items` | `relation_items` | `partner_country_id` (integer) | да | `relation_items(country_id, partner_country_id)` | `partner_country_id = 1` |
| 5 | `add_country_to_technology_items` | `technology_items` | `country_id` (integer) | да | уникальный `technology_items(technology_id, country_id)` | `country_id = 1` (по одной строке на технологию) |
| 6 | `add_country_to_political_actions` | `political_actions` | `country_id` (integer) | да | `political_actions(country_id)` | `country_id = 1` |
| 7 | (без миграции) `armies` | — | принадлежность выводится из владельца (Д8) | — | — | — |

Пояснения и требования к миграциям:

1. `null: true` во всех новых FK-колонках — сознательно, чтобы миграция прошла на любой существующей базе и чтобы обратная совместимость не зависела от порядка сидирования. Обязательность обеспечивается моделью и бэкфиллом (§ 11), а не `NOT NULL` в схеме.
2. Внешние ключи на `countries` не добавляем — в проекте FK объявлены только для части таблиц (`db/schema.rb:499-513`), но индексы обязательны: почти все новые запросы фильтруют по стране.
3. Уникальный индекс `(technology_id, country_id)` до наката проверить на дубликаты (сейчас по одной строке на технологию, `db/seeds/2_politics.rb:146-152`, но ручные правки через `technology_items#create` могли создать лишние). Pre-check-запрос — § 12, п. 1.
4. Колонка `armies.country_id` не вводится (Д8). Если в ходе реализации выяснится, что выборка «армии государства» слишком тяжёлая, колонка добавляется отдельной миграцией вместе с кэш-синхронизацией.
5. Индексы по `partner_country_id` — составной `(country_id, partner_country_id)`: чтение пары всегда идёт по обоим концам.

Итоговый состав новых/изменённых полей:

```
countries            + playable boolean default false
players              + country_id integer null
guilds               + country_id integer null
relation_items       + partner_country_id integer null
technology_items     + country_id integer null
political_actions    + country_id integer null
```

---

## 7. Изменения JSON-параметров (без миграций)

| Где | Было | Стало | Причина |
|---|---|---|---|
| `countries.params['relation_points']` | `2` (число) | `{"1" => 2}` (хэш по `partner_country_id`) | торговые очки относятся к паре государств (Д10) |
| `countries.params['last_trade_turnover']` | `45000` | `{"1" => 45000}` | то же |
| `countries.params['embargo']` | `0/1` | без изменений | эмбарго — свойство государства, не пары |
| `players.params['income_taken']` | `true/false` | без изменений | флаг получения дохода на игроке (Д6, требование 7) |
| `GameParameter['many_teams'].params` | — | `{"enabled" => false}` | переключатель режима (§ 4) |

Механика доступа к `countries.params` — только через методы модели (в коде и в jbuilder), чтобы формат хэша не расползался: сейчас прямой доступ `country.params['relation_points']` есть в модели и во фронте (`app/models/country.rb:146-180, 216-290`, `era_front/src/views/dashboard/Relations.vue:76-120`).

---

## 8. Модели: ассоциации, скоупы, методы, валидации

### 8.1. `Country`

Добавить:

- `has_many :players` (первый играбельный совет и все игроки страны);
- `has_many :guilds`;
- `has_many :owned_armies, -> { where(owner_type: 'Country') }, class_name: 'Army', foreign_key: :owner_id` (для скоупа армий страны);
- `scope :playable, -> { where(playable: true) }`;
- `Country.current` / `Country.current=` (Thread-scoped, по образцу `Player.current`);
- `Country.current_or_default` → `current || find_by(id: RUS)`;
- `Country#relation_items_with(other)` — элементы пары в оба конца;
- `Country#relations_with(other)` — кэп ±2 + бонус «Третий Рим» для пары с «Русью» (Д4);
- `Country#relations(partner = Country.current)` — совместимый алиас: смысл «отношения со страной-партнёром», по умолчанию — с текущим государством (в one-team это «Русь» = сегодняшнее поведение); **устаревший вызов без аргумента сохранить на время миграции кода**;
- `Country#council`, `#council_players(job)`, `#council_jobs`;
- `Country#relation_points_for(partner)`, `#add_relation_points(partner, n)`, `#last_trade_turnover_for(partner)`, `#set_last_trade_turnover(partner, value)` (Д10);
- `Country#change_relations(count, entity, comment, partner: Country.current, force: false)` — сигнатура расширяется ключевым аргументом `partner`, все текущие вызовы (без `partner`) продолжают работать в one-team семантике;
- `Country#capture(region, how)` / `#join_peace`: бонусы влияния выдаются совету **этого** государства (сейчас — жёстко совету «Руси», `app/models/country.rb:367-372, 377-385`).

Валидации: `playable` не требует «команды»; `relations_with` не должен вызываться с `other == self` (возвращает 0 + предупреждение в лог).

### 8.2. `Player`

- `belongs_to :country, optional: true` + `before_validation :assign_default_country`;
- `scope :for_country(c)`, `scope :nobles` (обёртка над `player_type_id == 2`, сейчас фильтр дублируется во фронте: `era_front/src/pages/dashboard.vue:38`, `Ownerships.vue:24-27`, `PoliticalActions.vue:20-23`, `Armies.vue:64-70`);
- `income(country = Country.current)`, `income_base(country)`, `income_breakdown(country)`, `influence(country)` — фильтрация по региону страны (Д7);
- `income_breakdown` дополнительно возвращает `country_id` и `player.country_id` в ответе (см. § 9).

### 8.3. Резолвинг «игроки должности» (ключевая правка Д3)

Ввести единый метод и заменить им все обращения вида `Job.find_by_id(Job::X).players`:

```ruby
# вызвать от государства: Country.current.council_players(Job::KAZNACHEI)
```

Места, которые обязаны быть переведены (бэкенд):

| Файл:строка | Что делает | Как должно быть |
|---|---|---|
| `app/models/country.rb:368` | бонус Великого князя за присоединение | совет государства, присоединившего регион |
| `app/models/country.rb:381` | бонус Посла за присоединение страны миром | совет текущего государства |
| `app/models/building.rb:21` | бонус Зодчего за постройку | совет государства, где построено |
| `app/models/building.rb:56` | влияние Митрополита | совет текущего государства |
| `app/models/political_action.rb:134, 144` | «Именем Великого князя», «Набрать рекрутов» | совет текущего государства |
| `app/models/army.rb:158` | бонус Воеводы за победу | совет государства победившей армии |
| `app/models/game_parameter.rb:1065` | бонус Казначея за оплату расходов | совет текущего государства (в one-team — как сейчас) |
| `app/controllers/armies_controller.rb:68` | бонус Тайного советника за разведку | совет текущего государства |
| `app/controllers/regions_controller.rb:16` | бонус Великого князя за присоединение земли | совет текущего государства |
| `app/controllers/technology_items_controller.rb:42` | бонус Окольничего за открытие технологии | совет государства, открывшего технологию |
| `engines/vassals_and_robbers/.../political_action_extensions.rb:41, 54, 189` | выбор цели действия | совет текущего государства |
| `engines/vassals_and_robbers/.../player_extensions.rb:17` | проверка Казначея | совет текущего государства |

### 8.4. `Job`

Без схемных изменений (Д3). Добавить только обратный хелпер `Job#council_players(country = Country.current)` → `country.players.joins(:jobs).where(jobs: {id: id})` и `Job#holders_names(country)`. Константы id не трогаем.

### 8.5. `Technology` / `TechnologyItem`

- `TechnologyItem belongs_to :country` (optional) + валидация уникальности `(technology_id, country_id)`;
- `Technology#item_for(country)`, `#is_open(country = Country.current)`, `#open_it(country = Country.current)`, `#close_it(country = Country.current)`; текущие вызовы `is_open` без аргумента сохраняются и читают текущее государство (Д5);
- `TechnologyItem.add(value, comment, technology, entity = nil, country = Country.current)`.

### 8.6. `PoliticalAction`

- `belongs_to :country, optional: true` + `before_validation` (по умолчанию текущее государство);
- `scope :for_country(c)`, `scope :for_year(year)`;
- `PoliticalAction#modify_influence(value)` — выдаёт влияние **игроку**, начислять влияние «должности» нельзя (требование 4); сохраняется как есть, фиксируется тестом.

### 8.7. `Region`, `Settlement`, `PublicOrderItem`

- `Region` — `scope :for_country(c)`, `scope :foreign_to(c)`; `Region#captured_by(who_id, how)` — бонусы/логика не привязаны к `RUS` (сейчас `app/models/region.rb:42`), а к стране-получателю;
- `Settlement` — `scope :for_country(c)` через JOIN региона, `scope :foreign_to(c)`;
- `PublicOrderItem.add(value, comment, region = nil, entity = nil, country = Country.current)` — при `region = nil` применяется к регионам текущего государства (сейчас — к регионам «Руси», `app/models/public_order_item.rb:17`).

### 8.8. `Army`

- `Army#country`, `#country_id`, `scope :for_country(c)`, `scope :foreign_to(c)`, валидации владельца (Д8).

### 8.9. `RelationItem`

- `belongs_to :partner_country, class_name: 'Country', optional: true`;
- `RelationItem.add(value, comment, country, entity = nil, partner_country = Country.current)`;
- валидация: `country_id != partner_country_id` (самопары запрещены для новых записей).

---

## 9. Контракт API (что отдаём и что принимаем)

Изменения должны быть совместимыми: старые параметры остаются рабочими, новые — добавляются.

| Эндпоинт | Было | Стало |
|---|---|---|
| `GET /countries.json` | `?foreign=1` — все, кроме «Руси» | `?foreign=1` — все, кроме **текущего** государства; `?playable=1` — только играбельные |
| `GET /countries/:id.json` | `relations`, `relation_items`, `relation_points` (скаляр), `alliances` — союзы «Руси» с этой страной | `relations` — с текущим государством; `relations_by_country: {id: value}` — со всеми остальными; `relation_items` — элементы пары «текущее ↔ эта страна»; `relation_points` — для пары с текущим; `alliances` — союзы текущего государства с этой страной |
| `GET /regions.json` | `?foreign=0` — регионы «Руси», `?foreign=1` — остальные | `?foreign=0` — регионы текущего государства, `?foreign=1` — остальные; добавлен `?country_id=<id>` (явная страна, для Дашборда) |
| `GET /settlements.json` | без параметра — только регионы «Руси»; `?all=1` — все | без параметра — регионы текущего государства; `?country_id=<id>` — указанной; `?all=1` — все |
| `GET /players.json` | `?player_type_id=`, `?without_guild=1` | добавлен `?country_id=<id>`; в ответе игрока новое поле `country` (`{id, name, short_name, flag_image_name}`) и `country_id` |
| `GET /players/:id/income_breakdown.json` | разбивка по всем поселениям игрока | `?country_id=<id>` (по умолчанию — текущее государство); в ответе `country_id`, в каждой строке поселения `region_id`, `country_id` |
| `PATCH /players/:id/add_income.json`, `.../add_influence.json` | правка игрока | без изменений (уже на игроке), но `add_income` пишет `IncomeItem` с текущим годом |
| `GET /technologies.json` | `is_open` (один флаг), `technology_items` — все | `?country_id=<id>` (по умолчанию текущее); `is_open` — статус этого государства; `technology_items` — только элементы этого государства, каждый с `country_id` |
| `PATCH /technology_items/:id.json` | `{value}`, `?okolnichy_bonus=1` | без изменения сигнатуры; бонус Окольничего — совету государства элемента (Д5, § 8.3) |
| `GET /armies.json` | все активные армии | добавить `?country_id=<id>`, `?foreign=0|1` (относительно текущего государства); в ответе армии — `country_id`, `country` |
| `GET /political_actions.json` | все действия | `?country_id=<id>`, `?year=<год>`; в ответе `country_id` |
| `GET /jobs.json?nobles=1` | 10 должностей, в каждой `player_ids` — держатели по всей базе, `political_actions` — по всей базе | `?country_id=<id>` (по умолчанию текущее): `player_ids` — держатели **этого государства**, `political_actions` — действия этого государства |
| `PATCH /jobs/:id.json ?job[player_ids][]=X` | полная замена списка держателей должности | замена только в пределах текущего государства: держатели других государств сохраняются (иначе назначение в одном государстве стирает совет другого) |
| `GET /current_country.json`, `GET /login_country/:id.json` | — | новые: прочитать/выбрать текущее государство (`session[:country_id]`, § 4). Аналог `users#current_user` / `users#login` (`config/routes.rb:215-216`) |
| `GET /game_parameters.json` | все параметры | добавить `many_teams` в набор; в ответе — `enabled` |

Формат выбора страны для нового эндпоинта — как у пользователя (`GET /login/:id` → `users#login`), чтобы фронт переиспользовал тот же паттерн, что в `era_front/src/layouts/components/UserProfile.vue:26-31`.

---

## 10. Seeds

Задача: одна и та же кодовая база должна сидировать и одну команду, и несколько.

1. Список команд задаётся переменной окружения, читаемой seeds:

```
TEAMS="Русь"                 # режим one-team (по умолчанию)
TEAMS="Русь,Литва,Казань"    # режим many-teams
```

Названия сверяются с `countries.name` (id стран фиксированы, `app/models/country.rb:22-34`). Неизвестное имя — падение сидирования с понятным сообщением (лучше, чем молча сидировать не то).

2. Новый файл `db/seeds/1_1_teams.rb` (порядок загрузки — по алфавиту, `lib/tasks/custom_seed.rake:22-28`):
   - разбирает `TEAMS`, выставляет `countries.playable = true` для перечисленных;
   - пишет `GameParameter['many_teams'] = {enabled: TEAMS.size > 1}` (`find_or_create_by`, `identificator` — чтобы повторный `db:seed:all` не плодил записи);
   - создаёт советы: для каждого играбельного государства — свой набор знати (`Player` с `country_id`), своя гильдия купцов (`Guild.country_id`) при необходимости.

3. `db/seeds/1_players.rb` — создать 10 должностей как сейчас (id 1..10 не трогать) и привязать знати `country_id`; имена знати берутся по государствам (для «Руси» — текущий список `noble_names`, для остальных — из таблицы в `1_1_teams.rb`).

4. `db/seeds/2_politics.rb`:
   - `Country.create(... , playable: <из TEAMS>)`, `:74`;
   - `RelationItem.add(relations.to_i, "Ручная правка", country, nil, Country::RUS)` — второй конец пары заполняется явно (`:76`);
   - технологии: цикл по играбельным государствам, `TechnologyItem.add(0, "Изменить значение", t, nil, country)` (`:146-152`);
   - `PoliticalActionType` — без изменений (общий каталог, `:118-141`).

5. `db/seeds/3_resources_and_countries.rb` — регионы/поселения уже привязаны к странам через `country_id`; добавить только владельца-игрока в рамках его государства (в CSV `countries.csv` есть колонка `player_name`, `:100-102`).

6. `db/seeds/4_armies.rb` — владельцы армий: страна или знатный своего государства (валидация Д8).

7. `lib/tasks/custom_seed.rake` — добавить задачу `game:teams`:

```
rake game:teams TEAMS="Русь,Литва,Казань"
```

= `db:drop` + `db:create` + `db:migrate` + `db:seed:all` (то же, что `game:core`, `:44-56`), с проброшенным `TEAMS`. `game:core` без `TEAMS` = one-team (как сейчас).

Важно (проверено): `rake game:*` пересоздаёт базу, любой режим, выставленный только в БД, исчезает при следующем старте игры. Поэтому «правда» о режиме и списке команд живёт в seeds и переменной `TEAMS`.

---

## 11. Миграция существующих данных и обратная совместимость

Порядок наката на работающую базу:

1. `rails db:migrate` — добавляет поля без блокировок, значения `NULL`.
2. Бэкфилл (однократная задача `rails many_teams:backfill` или `rails runner`):

```ruby
Country.where(id: Country::RUS).update_all(playable: true)
Player.update_all(country_id: Country::RUS)
Guild.update_all(country_id: Country::RUS)
RelationItem.update_all(partner_country_id: Country::RUS)
TechnologyItem.update_all(country_id: Country::RUS)
PoliticalAction.update_all(country_id: Country::RUS)

# params: скаляры → хэши по паре
Country.find_each do |c|
  p = c.params || {}
  next if p['relation_points'].is_a?(Hash)
  pts  = p['relation_points'].to_i
  turn = p['last_trade_turnover'].to_i
  p['relation_points'] = { Country::RUS.to_s => pts }
  p['last_trade_turnover'] = { Country::RUS.to_s => turn }
  c.update_column(:params, p)
end
```

3. `GameParameter['many_teams'] = {enabled: false}` (`find_or_create_by`).

Ожидаемый результат бэкфилла в one-team режиме — поведение, идентичное текущему:

- `Country.current = РУС`, значит `Country#relations` = сегодняшнее значение;
- `players.country_id = РУС` — совет, влияние, доход резолвятся как сейчас;
- `technology_items.country_id = РУС` — открытие технологий идут в ту же строку, что и раньше;
- `political_actions.country_id = РУС` — «выполнено в этом году» считается как сейчас;
- `countries.playable = [РУС]` — Дашборд и переключатель вырождаются в один вариант.

Контрольные условия совместимости (проверяются п. 3 § 12):

- `regions.json?foreign=0` → тот же набор регионов, что до миграции;
- `players.json` → тот же набор и те же значения `income`, `influence`, `own_count`, только с новыми полями;
- `countries.json?foreign=1` → те же страны, `relations` те же числа;
- `technologies.json` → `is_open` те же 12 значений;
- `armies.json` → тот же набор, разбиение «Русь/Зарубеж» сохраняется.

Особый случай: строки `relation_items`, где после бэкфилла `country_id == partner_country_id` (самопары «Русь ↔ Русь»). Все читатели их игнорируют; отчёт для ручного разбора:

```ruby
RelationItem.where("country_id = partner_country_id").count
RelationItem.where("country_id = partner_country_id").group(:country_id).count
```

---

## 12. Тест-план этапа 1 и критерии приёмки

Проверки данных (rails console / psql):

1. Pre-check перед миграцией 5:

```ruby
TechnologyItem.group(:technology_id).having("count(*) > 1").count  # должно быть пусто
```

2. Пост-проверка бэкфилла:

```ruby
Player.where(country_id: nil).count           # 0
TechnologyItem.where(country_id: nil).count   # 0
PoliticalAction.where(country_id: nil).count  # 0
Country.where(playable: true).pluck(:name)    # ["Русь"] до включения many-teams
RelationItem.where(partner_country_id: nil).count # 0
```

3. Паритет API (снять JSON до и после миграции на одной и той же базе — `dumps/` + `restore-database.sh` из `era_scripts`):

```
GET /regions.json?foreign=0
GET /regions.json?foreign=1
GET /players.json
GET /countries.json?foreign=1
GET /technologies.json
GET /armies.json
GET /political_actions.json
```

Расхождение допустимо только в новых полях (`country_id`, `country`, `relations_by_country`, `playable`). Любое изменение существующих значений — дефект.

4. Сидирование (чистая база):

```
TEAMS="Русь" rake game:teams
```

Ожидаемые количества совпадают с текущими `rake game:core`: 12 стран, 12 технологий, 12 `technology_items`, 10 должностей, столько же игроков знати, `relation_items` — по одной «ручной правке» на страну.

```
TEAMS="Русь,Литва" rake game:teams
```

Ожидаемое: `Country.playable.count == 2`; `technology_items.count == 24`; знати на 9 больше; у каждого игрока `country_id` заполнен; `GameParameter['many_teams'].params['enabled'] == true`.

5. Скоупы и методы:

```ruby
Country.current = Country.find(Country::RUS)
p1 = Player.nobles.first
p1.income_breakdown(Country.find(Country::RUS))[:settlements].all? { |s| s[:country_id] == Country::RUS }  # true
c = Country.find(Country::LITHUANIA)
Country.find(Country::RUS).relations_with(c) == c.relations_with(Country.find(Country::RUS))  # true (одна величина на пару)
Army.for_country(Country.find(Country::RUS)).map(&:id).sort == ...  # сверка с ручным списком
```

Критерии приёмки (DoD) этапа 1:

- [ ] Все 6 миграций накатываются на копию текущей базы без потерь и откатываются (`db:rollback`).
- [ ] Бэкфилл идемпотентен (повторный прогон не меняет данные) и переводит существующую базу в состояние паритета.
- [ ] `rake game:teams TEAMS="Русь"` даёт данные, эквивалентные сегодняшним (сверка количеств и паритет API).
- [ ] `rake game:teams TEAMS="Русь,<вторая страна>"` даёт корректно разделённые данные (совет, технологии, отношения, политдействия, армии).
- [ ] `Country.current` подставляется на каждом запросе и во всех читателях, зависящих от государства; `Country::RUS` в новых ветках логики не появляется (кроме константы и обратной совместимости).
- [ ] Ни один существующий эндпоинт не удалён и не изменил формат существующих полей.
- [ ] Модельные валидации (игрок без страны, армия со «незнатным» владельцем-игроком, самопара отношений, дубль `technology_item`) покрыты тестами.
- [ ] Тест-план § 12 выполнен на копии боевой базы, отчёт о паритете приложен.

---

## 13. Риски и ограничения

| Риск | Оценка | Что делаем |
|---|---|---|
| Смена семантики `relations` (одна величина «страна → Русь» → пара) задевает читателей: цены ресурсов (`app/models/resource.rb:92-112, 145-152`), союзы (`app/views/countries/_country.json.jbuilder:18-38`), бонус «Третий Рим» | Высокий | Читатели остаются на алиасе `relations` с дефолтным партнёром = текущее государство; переход на `relations_with(partner)` — этап 2, по списку мест (приложение А, п. 5) |
| Уникальный индекс `technology_items(technology_id, country_id)` не накатится из-за дублей | Средний | Pre-check § 12 п. 1, дубли разбираются вручную/склейкой значений |
| Seeds не идемпотентны (повторный `db:seed:all` без drop дублирует записи) | Средний | В новых seed-файлах только `find_or_create_by`; договорённость: режим и команды меняются через `rake game:teams` (пересоздание), а не повторным сидированием |
| Движки `vassals_and_robbers` / `artel` Русь-центричны | Средний | Явно вне объёма; в many-teams режиме используются только с «Русью»; список мест — приложение А, п. 6 |
| Ручной выбор государства мастерами расходится с их ролью (мастер «Литвы» ушёл на экран «Руси») | Низкий | Переключатель в шапке + текущее государство всегда отображается; при необходимости — `users.default_country_id` (Q5) |
| Долгий бэкфилл на большой базе (12 стран/игроки — тысячи строк) | Низкий | `update_all` + `find_each`, офлайн-окно перед игрой |

---

## 14. Открытые вопросы (нужны решения заказчика)

- **Q1 (Д3, ключевой).** Знатный совет: подтверждаем вариант A — справочник 10 должностей общий, «свой совет» = свои игроки государства на этих должностях? Или нужны отдельные строки должностей на государство (вариант B) со своим набором политдействий на каждое государство? Рекомендация — A.
- **Q2 (Д4).** Отношения — одна величина на пару государств (не направленная)? Рекомендация — да.
- **Q3 (Д10, Д11).** Торговые очки: делаем их парными (страна-источник торговли ↔ страна-партнёр) и для этого заводим `guilds.country_id`? Или на этом этапе очки остаются «в разрезе страны-партнёра от текущего государства» и учитывают только гильдии «Руси» (меньше работы, но в many-teams некорректно)?
- **Q4 (Д6).** Флаг получения дохода `players.params['income_taken']` оставляем один на игрока (даже если у него владения в двух государствах)? Рекомендация — да, один на игрока, как сейчас.
- **Q5.** Нужна ли мастерам «страна по умолчанию» в профиле (`users.default_country_id`), чтобы при входе сразу поднималось своё государство, или достаточно ручного выбора в сессии?
- **Q6.** Список играбельных государств задаём только в seeds (`TEAMS`) или нужен редактор списка в интерфейсе («Служебное → Настройки»)?

---

## Приложение А. Инвентарь Русь-центричных мест (для этапа 1 — контракт, для этапа 2 — правки)

1. Прямое использование `Country::RUS` (29 вхождений, все обязаны стать `Country.current` либо параметром):

| Файл:строка | Смысл | Как должно быть |
|---|---|---|
| `app/models/political_action.rb:56, 63, 118, 246` | регионы, по которым бьёт эффект действия | регионы текущего государства |
| `app/models/player.rb:311, 367, 424, 434` | доход/влияние от церквей и строений | регионы текущего государства (§ 8.2) |
| `app/models/region.rb:42` | «присоединён к Руси» → бонусы ПО | страна-получатель (текущая) |
| `app/models/public_order_item.rb:17` | значение на все регионы Руси | регионы текущего государства |
| `app/controllers/plant_places_controller.rb:57` | место предприятия «у Руси» | текущее государство |
| `app/controllers/regions_controller.rb:7, 8, 14` | фильтры «свой/зарубеж», бонус князя | текущее государство |
| `app/controllers/countries_controller.rb:7` | `foreign=1` | всё, кроме текущего государства |
| `app/controllers/settlements_controller.rb:8` | поселения Руси | поселения текущего государства |
| `engines/vassals_and_robbers/...political_action_extensions.rb:121, 144, 175` | эффекты плагина, союз с Русью | вне объёма (движок Русь-центричен) |
| `engines/vassals_and_robbers/...checklist_validator.rb:69` | сюзерен — Русь | вне объёма |
| `engines/artel/...plant_places_controller_extensions.rb:16` | доступные страны = Русь + вассалы | вне объёма |

2. Константы должностей и выдачи «по должности»: `app/models/job.rb:14-30` (`Job::GRAND_PRINCE = 1` … `Job::METROPOLITAN_PINE`), перечень мест — § 8.3.

3. Технологии: `db/seeds/2_politics.rb:146-152`, `app/models/technology.rb:17-35`, чтение эффектов — `app/models/player.rb:316, 322`, `app/models/region.rb:36`, `app/models/plant_level.rb:10`, `app/controllers/plants_controller.rb:14, 18`, `app/controllers/plant_levels_controller.rb:7, 12`, `app/controllers/plant_places_controller.rb:17`, `app/views/regions/_region.json.jbuilder:12-20`, `app/views/technologies/_technology.json.jbuilder:1-4`.

4. Влияние/доход: `influence_items.player_id`, `income_items.player_id`, `players.params['income_taken']`, сброс флага в `app/models/game_parameter.rb:1084-1089`, аудит получения дохода `app/models/player.rb:7-18, 486-503`.

5. Читатели отношений: `app/models/resource.rb:92-93, 110-112, 145-152` (цены по уровню отношений), `app/views/countries/_country.json.jbuilder:6-38` (значение, элементы, союзы «Руси»), `era_front/src/views/dashboard/Relations.vue:12-120` (правки и очки), `app/models/country.rb:184-290` (начисление очков по товарообороту), `db/seeds/3_resources_and_countries.rb` (базовые отношения стран).

6. Русь-центричные места, остающиеся вне объёма: `engines/vassals_and_robbers/**`, `engines/artel/**`, `GameParameter#pay_state_expenses` / `unpay_state_expenses` (`app/models/game_parameter.rb:1108-1123`), годовые результаты (`sort_and_save_results` и далее, `:405-577`), мобильные эндпоинты (`config/routes.rb:36-52`).
