# ТЗ № 1. Этап 1: структура данных «несколько команд»

Паспорт документа

| Поле | Значение |
|---|---|
| Версия | 3.0 (на согласование) |
| Дата | 2026-10-16 |
| Ветка | `many_teams` в `eraofchange` и `era_front` |
| Область этапа | `eraofchange`: схема БД, миграции, модели, движки `vassals_and_robbers` и `artel`, расходы государства, годовые результаты игры, JSON-контракт API, seeds, rake-задачи. `era_front`: только контракт API (изменения экранов — этап 2) |
| Связанный документ | ТЗ № 2 «Функциональность»: `docs/many_teams/TZ-2-funkcionalnost.md` |
| Источник требований | Постановка заказчика от 2026-10-16 (разделы «Дашборд», «Информация о стране», «Политика», «Сражения») + уточнения того же дня: движки `vassals_and_robbers` и `artel` также дорабатываются; расходы государства подтверждаются для каждого государства; годовые результаты игры считаются для каждого государства |
| Критерий готовности этапа | Приложение всегда работает «в разрезе государства» (текущее государство), играбельно **любое** государство — признака «играбельное государство» нет и не вводится. Когда мастера работают за одну страну (как сегодня — «Русь»), мастер ничего не выбирает и всё работает как прежде. Когда команд несколько, данные государств разделены. Отдельного «режима на одну команду» в коде нет |

---

## 1. Контекст: что есть сейчас

Программа обслуживает одно государство. «Русь» жёстко зашита константой `Country::RUS = 1` (`eraofchange/app/models/country.rb:22`) и используется в 29 местах бэкенда (полный инвентарь — приложение А).

Фактическое состояние ключевых сущностей:

| Сущность | Как хранится сейчас | Где |
|---|---|---|
| Государства | `countries` (id, name, short_name, flag_image_name, params). Признака «играбельная» нет — и не вводится: играбельно любое государство | `db/schema.rb:151-158` |
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

Вывод: нужны три вещи — (1) «текущее государство» вместо `Country::RUS` (играбельно любое государство, отдельного признака не заводим), (2) привязка игрока к государству как опорная связь для совета, влияния, дохода и армий, (3) перевод трёх «одногосударственных» сущностей (технологии, отношения, политдействия) в разрез по государству.

---

## 2. Границы этапа

Входит:

- миграции схемы;
- ассоциации, скоупы, методы и валидации моделей;
- изменения форматов JSON-параметров (`countries.params`);
- контракт API: новые поля и параметры запросов (без изменений UI);
- seeds: раздельные данные по государствам (технологии — каждому государству, знать и гильдии — по своим);
- миграция существующих данных, обратная совместимость, тест-план данных;
- движки `vassals_and_robbers` (вассалитет, чек-листы, доход от вассалов) и `artel` — перевод на текущее государство (Д14, § 15);
- расходы государства: подтверждение оплаты по каждому государству (Д12, § 13);
- годовые результаты игры: ранжирование знати и купцов по каждому государству (Д13, § 14).

Не входит (отдельные этапы, согласуются отдельно):

- эффекты технологий (что именно даёт открытая технология) — прямо исключено заказчиком;
- эффекты политических действий — прямо исключено заказчиком;
- экономика: предприятия, рынок, караваны, товарооборот как отдельный экран;
- новые игровые механики движков (в объёме только перевод существующих механик на текущее государство);
- мобильные приложения `era_native`, `era_players`;
- интерфейс `era_front` — этап 2.

---

## 3. Термины

| Термин | Значение |
|---|---|
| Текущее государство | Государство, за которое сейчас работают мастера; источник всех «моих» данных в API; замена `Country::RUS`. Текущим может быть любое государство; по умолчанию — «Русь» |
| Совет государства | Игроки типа «Знать» (`player_type_id = 2`) этого государства в разрезе должностей |
| Пара отношений | Два государства A и B, между которыми считается одна величина отношений |
| Команда | Мастера, работающие за одно государство (не сущность БД) |

---

## 4. Единая модель: текущее государство

Отдельного «режима на несколько команд» и переключателя режимов **нет**. Поведение одно и то же всегда:

1. Приложение работает в разрезе **текущего государства**.
2. Текущим может быть **любое** государство: признака «играбельная страна» нет, список для выбора — все государства (`countries`).
3. Если мастера работают за одну страну (как сегодня — «Русь»), они ничего не выбирают: переключатель показывает эту страну, все данные — её, работа выглядит и ведёт себя как до доработки.
4. Когда команд несколько, они работают за разные страны, и данные разделяются по государствам. Никакой код при этом не «переключается»: правило одно — «данные текущего государства».

Правило разрешения `Country.current`:

1. `session[:country_id]`, если задан и такая страна существует;
2. иначе «Русь» (`Country::RUS`), если она есть в базе;
3. иначе первое государство по id (страховка для нестандартной базы).

Пункт 3 и правило разрешения ниже — это и есть «играю за одну страну, всё работает как прежде»: выбор не требуется, значение подставляется само.

Хранилище выбора — сессия (`session[:country_id]`), по образцу `session[:user_id]` (требование заказчика: «этот выбор сохраняется в сессию так же, как сохраняется user»). Новых колонок в `users` не вводим; «страна мастера по умолчанию» — см. открытый вопрос Q5.

---

## 5. Ключевые проектные решения

### Д1. Текущее государство — в сессии, по образцу выбора мастера

Решение: `session[:country_id]` + реестр страны в запросе через класс-аксессор `Country.current` / `Country.current=` (по образцу `Player.current`, `app/models/player.rb:45-60`) и `before_action :set_current_country` в `ApplicationController` рядом с `set_current_player` (`app/controllers/application_controller.rb:28-33`). Правило разрешения — § 4.

### Д2. Игрок привязан к государству

`players.country_id` — опорная связь всей модели. Через неё выводятся: совет государства, доход и влияние «по текущему государству», страна армий, принадлежащих знати.

Правило: `Player#country` не может быть пустым. Реализуется `belongs_to :country, optional: true` + `before_validation :assign_default_country` (значение по умолчанию — `Country.current || Country.find(Country::RUS)`), чтобы старый код и движки, создающие игроков без страны, не падали. Игрок без явно указанной страны попадает в текущее государство — как сегодня, когда все игроки были «руськими».

### Д3. Знатный совет: без дублирования строк `jobs`

Решение (вариант A, рекомендуется): должности `jobs` остаются единым справочником 10 записей с неизменными id (на них завязаны константы `Job::GRAND_PRINCE = 1` … `Job::GUILD_BOSS = 10`, `app/models/job.rb:14-23`). «Свой совет в каждом государстве» получается так: совет государства = `players.where(country_id: <государство>)` в разрезе `jobs_players`. То есть у каждого государства свои люди на тех же должностях — должности «дублируются» по составу, а не по строкам справочника.

Когда мастера работают за одну страну, результат совпадает с сегодняшним: один совет из 10 должностей.

Технически: `Country#council(job)` / `Country#council_players(job_id)`, `Country#council_jobs` (упорядоченный список должностей с занятыми из этого государства).

Отклонённые альтернативы:

- вариант B — `jobs.country_id` и копия 10 должностей на государство: ломает константы-id (придётся вводить `kind` и переписать ~15 вызовов `Job.find_by_id(Job::X)` — приложение А), а вместе с должностями придётся дублировать и `political_action_types` (они `belongs_to :job`, `app/models/political_action_type.rb:6-8`, наполняются из `pat_nobles.csv`/`pat_merchants.csv`, `db/seeds/2_politics.rb:118-141`) — это N×дублирование справочника действий и копии эффектов;
- вариант C — отдельная таблица `countries_jobs` (страна + должность + игрок): по сути то же, что вариант A, но с лишней таблицей, дублирующей `jobs_players` + `players.country_id`.

Вариант A требует минимальных правок: единственное реальное изменение — везде, где код берёт «игроков должности» (`Job.find_by_id(...).players`), брать их через государство (см. § 8.3 и ТЗ № 2 § 1.2).

### Д4. Отношения становятся парными

`relation_items.partner_country_id` — второй конец пары. Значение отношений пары (A,B) = сумма значений всех `relation_items`, где (country_id = A и partner_country_id = B) **или** (country_id = B и partner_country_id = A), с кэпом ±`Country::REL_RANGE` (±2).

Почему так: мастера обоих государств могут править одну и ту же пару со своей стороны, а величина остаётся одна на пару (как в игре «отношения России и Литвы» — одна шкала). Направленных отношений постановка не требует.

Обратная совместимость: при миграции все существующие строки получают `partner_country_id = Country::RUS` (1), что в точности воспроизводит нынешнюю семантику «страна → Русь». Когда мастера работают за одну страну («Русь») все пары получаются «Русь ↔ страна», и значения отношений те же, что сегодня.

Строки, где `country_id == partner_country_id` (самопара), всеми читателями игнорируются; такие строки в базе могут существовать (ручные правки по «Руси»), их список выводится отдельным отчётом для ручной разборки.

Бонус технологии «Москва — Третий Рим» (`Country#relations`, `app/models/country.rb:351-356`) сохраняется как бонус **пары с «Русью»**: начисляется, если один конец пары — `RUS`, а второй — одно из {Пермь, Вятка, Рязань, Тверь, Новгород}. При разных составах команд расчёт бонуса не меняется.

### Д5. Технологии: номенклатура общая, факт открытия — на государство

`technology_items.country_id` + уникальный индекс `(technology_id, country_id)`. Номенклатура (`technologies`) и описания не меняются. Методы становятся контекстными:

- `Technology#item_for(country)`, `Technology#is_open(country = Country.current)`, `#open_it(country = Country.current)`, `#close_it(country = Country.current)`.

Важно: **эффекты** технологий (что даёт `is_open == 1`, например `player.rb:316` «Юрьев день», `region.rb:36` «Помазанник божий», `plant_level.rb:10` «Технические училища») на этом этапе не пересматриваются. Так как у методов появляется дефолт `Country.current`, все существующие вызовы эффектов продолжают читать статус текущего государства: при игре за «Русь» это ровно сегодняшнее поведение.

### Д6. Влияние и доход остаются на игроке (фиксация контракта, схемных изменений нет)

- Влияние: `influence_items.player_id`. «Привязано к игроку, а не к должности» — уже так; на этом этапе фиксируем правило и убираем единственный способ «повесить» влияние на должность: выдачи влияния по должности (`Job.find_by_id(Job::X).players`, приложение А, п. 2) должны резолвиться в игроков текущего государства, а не в «глобальных» держателей должности.
- Доход: `income_items.player_id` + `players.params['income_taken']`. Флаг получения дохода живёт на игроке, должностей не касается. Схема не меняется; меняется источник сумм — см. § 8.2.

### Д7. Доход считается только от владений текущего государства (без схемных изменений)

Требование 6: «доходы должны показываться от владений текущей страны, принадлежащих текущим игрокам». Владение игрока — поселение (`settlements.player_id`), а страна определяется регионом (`settlements.region_id → regions.country_id`). Значит достаточно скоупа, новых колонок не нужно:

- `Player#income_breakdown(country = Country.current)` — только поселения игрока, у которых регион принадлежит указанному государству;
- `Player#income(country = Country.current)`, `Player#income_base(country = Country.current)`, `Player#influence(country = Country.current)`;
- надбавки «по должности» (`Государь` → торговая надбавка, `Митрополит` → доход от церквей, `app/models/player.rb:296-318, 355-372`) ищут должность **в совете текущего государства** и церкви — в регионах текущего государства (сейчас жёстко `regions.country_id = Country::RUS`, `app/models/player.rb:311, 367, 424, 434`).

Когда мастера работают за одну страну суммы совпадают с сегодняшними.

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

Так как отношения становятся парными (Д4), эти величины относятся к паре (кто торгует ↔ с кем), поэтому формат меняется на хэш по `partner_country_id`:

```json
"relation_points":     { "1": 2 },
"last_trade_turnover": { "1": 45000 }
```

Бэкфилл: существующий скаляр переносится в ключ `"1"` («Русь»). Когда мастера работают за одну страну поведение кнопки «улучшить через торговлю» и начисления очков не отличается от сегодняшнего.

Чтение/запись — методы `Country#relation_points_for(partner)`, `#add_relation_points(partner, n)`, `#last_trade_turnover_for(partner)`, `#set_last_trade_turnover(partner, v)`; прямой доступ к `params['relation_points']` в коде и на фронте убирается.

Зависимость: корректно определить, **чьи** караваны считаются в паре, можно только зная государство гильдии → `guilds.country_id` (Д11) либо, если Д11 не делаем, очки начисляются от караванов гильдий текущего государства. Решение — открытый вопрос Q3.

### Д11. Государство у гильдии (зависимость Д10)

`guilds.country_id` (nullable, бэкфилл = «Русь»). Нужна только для корректного начисления торговых очков по паре и для будущего разделения экономики по командам. Экран экономики на этом этапе не меняется, когда мастера работают за одну страну поведение не меняется.

---

## 5.1. Решения по расходам, годовым результатам и движкам

### Д12. Расходы государства — флаг на государстве и год

Сейчас: один флаг на всю игру — `GameParameter.find_by(identificator: "current_year").params["state_expenses"]` (`app/models/game_parameter.rb:1108-1121`), сбрасывается при смене года (`:1061-1080`), аудит — на `GameParameter` (`:5-40`), статистика — `audits_controller#get_state_expenses_stats` (`app/controllers/audits_controller.rb:350-388`), UI — кнопка в шапке (`era_front/src/layouts/components/DefaultLayoutWithVerticalNav.vue:20-70`), уведомления — `Notifications.vue:575-590`.

Решение: флаг переезжает в `countries.params['state_expenses']` как хэш по году:

```json
"state_expenses": { "3": true, "4": false }
```

- `Country#state_expenses_paid?(year = GameParameter.current_year)`, `#pay_state_expenses(year)`, `#unpay_state_expenses(year)`;
- `GameParameter.pay_state_expenses(country = Country.current)` / `unpay_state_expenses(country = Country.current)` — сигнатуры расширяются, текущие вызовы без аргумента сохраняются;
- `GameParameter#increase_year`: цикл по всем государствам (`Country.find_each`) — неплатившему `PublicOrderItem.add(NO_STATE_EXPENSES, "Не оплачены расходы", nil, nil, country)` (в его регионы), платившему — бонус влияния Казначею **этого** государства; после цикла флаг нового года у каждого государства — `false`;
- аудит: из `GameParameter#should_audit?` / `state_expenses_changed?` / `audit_comment` ветка расходов убирается (остаётся смена года). Аудит оплаты — на `Country` (он уже `audited`, `app/models/country.rb:2`): комментарии «Оплачены госрасходы за N год (государство X)» / «Отменена оплата госрасходов за N год (государство X)», `Country#should_audit?` — только когда менялся `params['state_expenses']` (иначе аудит по стране разрастётся от любых правок `params`);
- статистика: `audits_controller#get_state_expenses_stats` читает аудиты `Country` (изменения `params['state_expenses']`) и группирует по государству; в `detailed_yearly_stats` добавляется разбивка `by_country`; аудиты `GameParameter` за прошедшие до перехода периоды читаются как раньше (иначе историческая статистика теряется);
- бэкфилл: текущее значение переносится в `{ <current_year> => <значение> }` для «Руси».

Когда мастера работают за одну страну поведение совпадает с нынешним: одна кнопка, один флаг, те же уведомления; в статистике добавляется название государства.

### Д13. Годовые результаты игры — по каждому государству

Сейчас результаты считаются живьём и по всей базе:

| Что | Где | Проблема при нескольких командах |
|---|---|---|
| Знать | `GameParameter.show_noble_results` (`app/models/game_parameter.rb:324-346`) — все `Player` типа «Знать», сортировка по `player.influence` | в таблицу попадает знать всех государств |
| Купцы | `show_sorted_results` (`:516-570`) — все гильдии, капитал = деньги + стоимость предприятий | гильдии всех государств в одной таблице |
| Экранный режим | `display_results` / `change_results_display` (`:348-356`) — один `params['display']` | у команд разные подэкраны, настройка одна |
| Настройки показа | `get_merchant_results_settings` / `update_merchant_results_settings` (`:358-403`) | то же: одни настройки на всех |
| API | `game_parameters#screen_bundle`, `#show_sorted_results`, `#show_noble_results`, `#change_results_display`, `#save_sorted_results`, `#update_results`, `#delete_result`, `#clear_results` (`config/routes.rb:55-66`) | нет параметра государства и года |

Решение:

1. **Ранжирование в разрезе государства:**
   - `GameParameter.show_noble_results(country = Country.current)` — знать этого государства, влияние через `Player#influence(country)` (Д7);
   - `GameParameter.show_sorted_results(sort_by: :capital, country = Country.current)` — гильдии этого государства (`guilds.country_id`, Д11); гильдии без страны (legacy, `country_id = nil`) попадают в выборку только при `country = nil`;
   - сортировка/места — как сейчас (`sort_and_rank_results`, `find_cap_per_pl`), но по отфильтрованному списку.
2. **Экранные настройки — по государству:** `GameParameter('results').params['display']` и хэш настроек показа становятся хэшами по `country_id`:
   ```json
   "display": { "1": "noblesResults" },
   "merchant_settings": { "1": { "show_cap_per_player": true, "intelligence_data_status": {} } }
   ```
   Доступ — только через методы: `GameParameter.display_results(country = Country.current)`, `change_results_display(string, country = Country.current)`, `get_merchant_results_settings(country = Country.current)`, `update_merchant_results_settings(settings, country = Country.current)`.
3. **Снимок года** (чтобы «годовые результаты» были годовыми, а не «переписывались» новым годом): при `increase_year` вызывается `GameParameter.snapshot_year_results(year = current_year)` **до** смены года и сохраняет срез по каждому государству:
   ```json
   "by_year": {
     "3": {
       "1": { "nobles": [ { "noble_name": "…", "noble_influence": 12, "place": 1 } ],
              "merchants": [ { "player": "Гильдия…", "capital": 100000, "place": 1 } ],
              "closed_at": "2026-10-16T18:00:00Z" }
     }
   }
   ```
   Чтение: `GameParameter.results_for_year(year, country)`, `GameParameter.results_years`. Текущий год показывается живым расчётом, прошедшие — снимком. Снимок идемпотентен: повторный вызов для того же года не перезаписывает непустой срез (кроме явного `force: true`).
   Если заказчику нужны только текущие standings без истории — п. 3 вычёркивается без влияния на пп. 1–2 (вопрос Q7).
4. Чтение/запись `params` записи `results` — только методами модели: прямой доступ `GameParameter.find_by(identificator: "results").params[...]` из кода убирается (сейчас есть в `game_parameter.rb` и в `game_parameters_controller.rb`).

### Д14. Движки (`engines`) — перевод на текущее государство

Оба движка «одногосударственные»: «Русь» — безусловный сюзерен в `vassals_and_robbers` и единственный субъект экономики в `artel`. Полный инвентарь — § 15.

#### Д14.1. `vassals_and_robbers` (вассалитет, чек-листы, разбой)

1. **Вассалитет становится своим у каждого государства**: новая колонка `vassals_and_robbers_checklists.sovereign_country_id` (миграция 6, бэкфилл = «Русь»). Уникальность сейчас — по `vassal_country_id` (`engines/vassals_and_robbers/app/models/vassals_and_robbers/checklist.rb:8`); становится составной `(sovereign_country_id, vassal_country_id)`: у каждого сюзерена свой список вассалов, при этом одно государство остаётся вассалом только одного сюзерена.
2. **Флаг установленного вассалитета** в `checklist.params` ключуется парой вместо одиночного ключа:
   ```json
   "vassalage": { "1": { "5": true } }
   ```
   (было `"vassal_5_established": true`). Старые ключи мигрируются в пару с «Русью» (бэкфилл).
3. **Проверки условий чек-листа — в разрезе сюзерена чек-листа** (`checklist_validator.rb`): армии — знать сюзерена; отношения — `relations_with(сюзерен)`; союз — `Alliance.where(country_id: сюзерен)`; технологии — `Technology#is_open(сюзерен)`; товарооборот — пара (сюзерен ↔ проверяемая страна); предприятия — построенные игроками/гильдиями сюзерена; общественный порядок и строения — в регионах сюзерена.
4. **Политдействия движка** (`political_action_extensions.rb:41, 54, 121, 144, 175`): `Country::RUS` → `Country.current`; союз заключается текущим государством, регионы для эффектов — регионы текущего государства, совет — `Country.current.council_players(...)`.
5. **Доход от вассалов** (`player_extensions.rb:17`): Казначей получает доход от вассалов **своего** государства: `PlayerExtensions.calculate_vassal_income(country)` — по вассальным чек-листам этого сюзерена. Настройка `GameParameter('vassalage_settings').params['vassal_incomes']` из `{вассал => сумма}` становится `{сюзерен => {вассал => сумма}}` (бэкфилл: всё «Руси»).
6. **Доступные места строительства** (`plant_places_controller_extensions.rb:16`): `allowed_country_ids = [Country.current.id] + вассалы текущего государства`; технология — `is_open(Country.current)`.
7. **Контроллер чек-листов** (`checklists_controller.rb`): выборка по сюзерену = `Country.current` (явный `?country_id=`), в ответе — `sovereign_country`, отношения — с текущим государством.
8. **Seeds движка:** `0_vassalage_settings.rb` — суммы по сюзеренам; `2_vassal_checklists.rb` — `sovereign_country_id = Country::RUS`; `5_politics.rb`, `3_guilds_and_plants.rb`, `4_example_seed.rb` — данные «за Русь», как сейчас; чек-листы создаются для тех государств, у которых по данным seeds есть вассальные страны.

#### Д14.2. `artel` (игра «Артель»: гильдии, предприятия без регионов, ресурсы без страны)

Особенность движка: включается переменной `ENV['ACTIVE_GAME'] == 'artel'`, ресурсы хранятся с `country_id = nil`, цены берутся по уровню отношений `0`, предприятия принадлежат только гильдии и не привязаны к региону.

1. `Technology.is_open` → `is_open(Country.current)` (`engines/artel/app/controllers/concerns/plant_places_controller_extensions.rb:14`).
2. Ресурсы: номенклатура остаётся общей (одна строка на ресурс, `country_id = nil` — как сейчас), но все методы работают в контексте текущего государства: `Resource.country_filter(Country.current.id, resources)`, `Resource.send_caravan(Country.current.id, ...)`, `calculate_cost`, `show_prices`. Караван отправляется от текущего государства, товарооборот и торговые очки (Д10) начисляются паре «текущее государство ↔ страна-партнёр»; ключ уровня отношений — `0` при отсутствии пары (как сейчас), значение пары — при её наличии.
3. Гильдии: владение предприятиями ограничивается гильдией текущего государства (`plants_controller_extensions#write_economic_subject`: `Guild.where(country_id: Country.current.id)`), `PlantExtensions#artel_plant_belongs_to_guild` — валидация «предприятие принадлежит гильдии этого государства».
4. Доступные места строительства (`plant_places_controller_extensions`): механика прежняя (гильдия, без региона), государство и технология — из контекста.
5. Seeds движка (`engines/artel/db/seeds/0_economics.rb`): ресурсы и цены — общие; гильдия — своего государства (совместно с Д11).
6. Совместимость: когда мастера работают за одну страну (`ACTIVE_GAME=artel`) цены, караваны и предприятия работают как прежде.

---

## 6. Изменения схемы БД

Порядок миграций и состав:

| № | Имя миграции | Таблица | Изменение | Null | Индекс | Бэкфилл |
|---|---|---|---|---|---|---|
| 1 | `add_country_to_players` | `players` | `country_id` (integer) | да | `players(country_id)` | `country_id = 1` |
| 2 | `add_country_to_guilds` | `guilds` | `country_id` (integer) | да | `guilds(country_id)` | `country_id = 1` |
| 3 | `add_partner_country_to_relation_items` | `relation_items` | `partner_country_id` (integer) | да | `relation_items(country_id, partner_country_id)` | `partner_country_id = 1` |
| 4 | `add_country_to_technology_items` | `technology_items` | `country_id` (integer) | да | уникальный `technology_items(technology_id, country_id)` | `country_id = 1` (по одной строке на технологию) |
| 5 | `add_country_to_political_actions` | `political_actions` | `country_id` (integer) | да | `political_actions(country_id)` | `country_id = 1` |
| 6 | `add_sovereign_country_to_vassals_and_robbers_checklists` (движок) | `vassals_and_robbers_checklists` | `sovereign_country_id` (integer) + уникальный составной индекс `(sovereign_country_id, vassal_country_id)` вместо уникального `(vassal_country_id)` | да | уникальный составной | `sovereign_country_id = 1` («Русь») |

Пояснения и требования к миграциям:

1. `null: true` во всех новых FK-колонках — сознательно, чтобы миграция прошла на любой существующей базе и чтобы обратная совместимость не зависела от порядка сидирования. Обязательность обеспечивается моделью и бэкфиллом (§ 11), а не `NOT NULL` в схеме.
2. Внешние ключи на `countries` не добавляем — в проекте FK объявлены только для части таблиц (`db/schema.rb:499-513`), но индексы обязательны: почти все новые запросы фильтруют по стране.
3. Уникальный индекс `(technology_id, country_id)` до наката проверить на дубликаты (сейчас по одной строке на технологию, `db/seeds/2_politics.rb:146-152`, но ручные правки через `technology_items#create` могли создать лишние). Pre-check-запрос — § 12, п. 1.
4. Колонка `armies.country_id` не вводится (Д8) — миграции по `armies` нет вовсе. Если в ходе реализации выяснится, что выборка «армии государства» слишком тяжёлая, колонка добавляется отдельной миграцией вместе с кэш-синхронизацией.
5. Индексы по `partner_country_id` — составной `(country_id, partner_country_id)`: чтение пары всегда идёт по обоим концам.
6. Миграция 6 лежит в движке (`engines/vassals_and_robbers/db/migrate/`) и накатывается общей задачей `db:migrate`. Перед накатом проверить, что нет двух чек-листов с одинаковым `vassal_country_id` (движок делал `find_or_create_by`), и что ни один `vassal_country_id` не равен `sovereign_country_id`.

Итоговый состав новых/изменённых полей:

```
players              + country_id integer null
guilds               + country_id integer null
relation_items       + partner_country_id integer null
technology_items     + country_id integer null
political_actions    + country_id integer null
vassals_and_robbers_checklists + sovereign_country_id integer null (движок)
```

Схемных изменений для расходов государства и годовых результатов нет: оба хранятся в `params` (см. § 7).

---

## 7. Изменения JSON-параметров (без миграций)

| Где | Было | Стало | Причина |
|---|---|---|---|
| `countries.params['relation_points']` | `2` (число) | `{"1" => 2}` (хэш по `partner_country_id`) | торговые очки относятся к паре государств (Д10) |
| `countries.params['last_trade_turnover']` | `45000` | `{"1" => 45000}` | то же |
| `countries.params['embargo']` | `0/1` | без изменений | эмбарго — свойство государства, не пары |
| `players.params['income_taken']` | `true/false` | без изменений | флаг получения дохода на игроке (Д6, требование 7) |
| `countries.params['state_expenses']` | — (флаг жил в `GameParameter('current_year').params['state_expenses']`) | `{"3" => true}` — по году (Д12) | подтверждение расходов у каждого государства своё |
| `GameParameter('results').params['display']` | `"noblesResults"` (скаляр) | `{"1" => "noblesResults"}` по `country_id` (Д13) | у каждой команды свой подэкран результатов |
| `GameParameter('results').params` (настройки показа) | скаляры (`show_cap_per_player` и др.) | хэш `merchant_settings` по `country_id` (Д13) | настройки экрана результатов у каждой команды свои |
| `GameParameter('results').params['by_year']` | — | новый: снимки результатов по годам и государствам (Д13 п. 3) | «годовые результаты» должны быть годовыми |
| `GameParameter('vassalage_settings').params['vassal_incomes']` | `{вассал => сумма}` | `{сюзерен => {вассал => сумма}}` (Д14.1) | доход от вассалов у каждого сюзерена свой |
| `vassals_and_robbers_checklists.params` | `{"vassal_5_established" => true}` | `{"vassalage" => {"1" => {"5" => true}}}` (Д14.1) | флаг вассалитета — по паре государств |

Новых `GameParameter` этот этап не вводит: состав команд не настраивается вообще — играбельно любое государство, а роль «моё государство» играет текущее государство сессии.

Механика доступа к `countries.params` — только через методы модели (в коде и в jbuilder), чтобы формат хэша не расползался: сейчас прямой доступ `country.params['relation_points']` есть в модели и во фронте (`app/models/country.rb:146-180, 216-290`, `era_front/src/views/dashboard/Relations.vue:76-120`).

---

## 8. Модели: ассоциации, скоупы, методы, валидации

### 8.1. `Country`

Добавить:

- `has_many :players` (игроки государства, включая совет);
- `has_many :guilds`;
- `has_many :owned_armies, -> { where(owner_type: 'Country') }, class_name: 'Army', foreign_key: :owner_id` (для скоупа армий страны);
- `Country.current` / `Country.current=` (Thread-scoped, по образцу `Player.current`); правило разрешения — § 4;
- `Country#relation_items_with(other)` — элементы пары в оба конца;
- `Country#relations_with(other)` — кэп ±2 + бонус «Третий Рим» для пары с «Русью» (Д4);
- `Country#relations(partner = Country.current)` — совместимый алиас: смысл «отношения со страной-партнёром», по умолчанию — с текущим государством (при игре за «Русь» это сегодняшнее поведение); **устаревший вызов без аргумента сохранить на время миграции кода**;
- `Country#council`, `#council_players(job)`, `#council_jobs`;
- `Country#relation_points_for(partner)`, `#add_relation_points(partner, n)`, `#last_trade_turnover_for(partner)`, `#set_last_trade_turnover(partner, value)` (Д10);
- `Country#change_relations(count, entity, comment, partner: Country.current, force: false)` — сигнатура расширяется ключевым аргументом `partner`, все текущие вызовы (без `partner`) продолжают работать в прежней семантике;
- `Country#capture(region, how)` / `#join_peace`: бонусы влияния выдаются совету **этого** государства (сейчас — жёстко совету «Руси», `app/models/country.rb:367-372, 377-385`).

Валидации: `relations_with` не должен вызываться с `other == self` (возвращает 0 + предупреждение в лог).

### 8.2. `Player`

- `belongs_to :country, optional: true` + `before_validation :assign_default_country`;
- `scope :for_country(c)`, `scope :nobles` (обёртка над `player_type_id == 2`, сейчас фильтр дублируется во фронте: `era_front/src/pages/dashboard.vue:38`, `Ownerships.vue:24-27`, `PoliticalActions.vue:20-23`, `Armies.vue:64-70`);
- `income(country = Country.current)`, `income_base(country)`, `income_breakdown(country)`, `influence(country)` — фильтрация по региону страны (Д7);
- `income_breakdown` дополнительно возвращает `country_id` игрока и `country_id` в каждой строке поселения (см. § 9).

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
| `app/models/game_parameter.rb:1065` | бонус Казначея за оплату расходов | совет текущего государства (при одном государстве — как сейчас) |
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
- `PoliticalAction#modify_influence(value)` — выдаёт влияние **игроку**; начисление влияния «должности» недопустимо (требование 4), покрывается тестом.

### 8.7. `Region`, `Settlement`, `PublicOrderItem`

- `Region` — `scope :for_country(c)`, `scope :foreign_to(c)`; `Region#captured_by(who_id, how)` — бонусы/логика привязаны к стране-получателю, а не к `RUS` (сейчас `app/models/region.rb:42`);
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

Изменения должны быть совместимыми: старые параметры остаются рабочими, новые — добавляются. «Текущее государство» подставляется по правилу § 4; когда мастера работают за одну страну («Русь»), результат тот же, что сегодня.

| Эндпоинт | Было | Стало |
|---|---|---|
| `GET /countries.json` | `?foreign=1` — все, кроме «Руси» | без параметров — все государства (список для выбора текущего); `?foreign=1` — все, кроме **текущего** государства |
| `GET /countries/:id.json` | `relations`, `relation_items`, `relation_points` (скаляр), `alliances` — союзы «Руси» с этой страной | `relations` — с текущим государством; `relations_by_country: {id: value}` — со всеми остальными; `relation_items` — элементы пары «текущее ↔ эта страна»; `relation_points` — для пары с текущим; `alliances` — союзы текущего государства с этой страной |
| `GET /regions.json` | `?foreign=0` — регионы «Руси», `?foreign=1` — остальные | `?foreign=0` — регионы текущего государства, `?foreign=1` — остальные; добавлен `?country_id=<id>` (явная страна, для Дашборда) |
| `GET /settlements.json` | без параметра — только регионы «Руси»; `?all=1` — все | без параметра — регионы текущего государства; `?country_id=<id>` — указанной; `?all=1` — все |
| `GET /players.json` | `?player_type_id=`, `?without_guild=1` | добавлен `?country_id=<id>`; в ответе игрока новое поле `country` (`{id, name, short_name, flag_image_name}`) и `country_id` |
| `GET /players/:id/income_breakdown.json` | разбивка по всем поселениям игрока | `?country_id=<id>` (по умолчанию — текущее государство); в ответе `country_id` игрока, в каждой строке поселения `region_id`, `country_id` |
| `PATCH /players/:id/add_income.json`, `.../add_influence.json` | правка игрока | без изменений (уже на игроке), но `add_income` пишет `IncomeItem` с текущим годом |
| `GET /technologies.json` | `is_open` (один флаг), `technology_items` — все | `?country_id=<id>` (по умолчанию текущее): `is_open` — статус этого государства; `technology_items` — только элементы этого государства, каждый с `country_id` |
| `PATCH /technology_items/:id.json` | `{value}`, `?okolnichy_bonus=1` | без изменения сигнатуры; бонус Окольничего — совету государства элемента (Д5, § 8.3) |
| `GET /armies.json` | все активные армии | добавить `?country_id=<id>`, `?foreign=0|1` (относительно текущего государства); в ответе армии — `country_id`, `country` |
| `GET /political_actions.json` | все действия | `?country_id=<id>`, `?year=<год>`; в ответе `country_id` |
| `PATCH /game_parameters/pay_state_expenses.json`, `.../unpay_state_expenses.json` | без параметров (флаг на всю игру) | опциональный `?country_id=<id>` (по умолчанию текущее государство); в ответе `country_id`, `year` (Д12) |
| `GET /game_parameters/show_noble_results`, `.../show_sorted_results`, `.../screen_bundle`, `.../display_results` | без параметров | `?country_id=<id>`, `?year=<год>`; по умолчанию — текущее государство и текущий год; в ответе `country_id` (и `year` для снимков) (Д13) |
| `PATCH /game_parameters/change_results_display`, `.../update_merchant_results_settings`, `.../clear_results`, `.../update_results`, `.../delete_result` | без параметров | принимают `country_id` (по умолчанию текущее); `clear_results` без `country_id` = очистка всех государств (только для главного мастера) |
| `GET /vassals_and_robbers/checklists.json` | все чек-листы, сюзерен = «Русь» | только чек-листы текущего сюзерена (`?country_id=<id>`), в ответе `sovereign_country` (Д14.1) |
| `GET /plant_places/available_places.json` | доступные страны = «Русь» + её вассалы | текущее государство + его вассалы (Д14.1) |
| `GET /jobs.json?nobles=1` | 10 должностей, в каждой `player_ids` — держатели по всей базе, `political_actions` — по всей базе | `?country_id=<id>` (по умолчанию текущее): `player_ids` — держатели **этого государства**, `political_actions` — действия этого государства |
| `PATCH /jobs/:id.json ?job[player_ids][]=X` | полная замена списка держателей должности | замена только в пределах текущего государства: держатели других государств сохраняются (иначе назначение в одном государстве стирает совет другого) |
| `GET /current_country.json`, `GET /login_country/:id.json` | — | новые: прочитать/выбрать текущее государство (`session[:country_id]`, § 4). Аналог `users#current_user` / `users#login` (`config/routes.rb:215-216`) |
| `GET /game_parameters.json` | без изменений | без изменений: настройки режима команд не появляется |

Формат выбора страны для нового эндпоинта — как у пользователя (`GET /login/:id` → `users#login`), чтобы фронт переиспользовал тот же паттерн, что в `era_front/src/layouts/components/UserProfile.vue:26-31`.

---

## 10. Seeds

Задача: одна и та же кодовая база даёт игру и за одну страну, и за несколько. Признака «играбельное государство» нет, поэтому seeds ничего не «включают» — они создают данные, разделённые по государствам, сразу для всех.

1. Раздельные данные создаются для всех государств (id стран фиксированы, `app/models/country.rb:22-34` — 12 государств):
   - `technology_items` — по одной строке на каждую пару «технология × государство» (12 × 12 = 144 строки, значение 0 «не открыта»): `TechnologyItem.add(0, "Изменить значение", t, nil, country)`;
   - знать (`Player` типа «Знать») — с `country_id` своего государства по данным seeds (для «Руси» — текущий список `noble_names` / `pat_nobles.csv`);
   - гильдии купцов — с `country_id` своего государства (`Guild.country_id`);
   - регионы и поселения уже привязаны к странам через `country_id` (`3_resources_and_countries.rb`), владелец-игрок остаётся в рамках своего государства (в `countries.csv` есть колонка `player_name`, `:100-102`).

2. Новый файл `db/seeds/1_1_countries.rb` (порядок загрузки — по алфавиту, `lib/tasks/custom_seed.rake:22-28`):
   - привязывает знати `country_id` и создаёт гильдии по тем государствам, где по seeds есть купцы;
   - идемпотентен (`find_or_create_by`): повторный `db:seed:all` без пересоздания базы не дублирует записи.

3. `db/seeds/1_players.rb` — 10 должностей как сейчас (id 1..10 не трогать), у знати заполняется `country_id`.

4. `db/seeds/2_politics.rb`:
   - `Country.create(...)` — без признака играбельности (`:74`);
   - `RelationItem.add(relations.to_i, "Ручная правка", country, nil, Country::RUS)` — второй конец пары заполняется явно (`:76`);
   - технологии: цикл по всем государствам, `TechnologyItem.add(0, "Изменить значение", t, nil, country)` (`:146-152`);
   - `PoliticalActionType` — без изменений (общий каталог, `:118-141`).

5. `db/seeds/4_armies.rb` — владельцы армий: страна или знатный своего государства (валидация Д8).

6. `lib/tasks/custom_seed.rake` — новых задач не нужно: запуск игры остаётся `rake game:core` (`:44-56`), переменных окружения нет. Какая страна будет текущей, определяет мастер в интерфейсе (по умолчанию — «Русь»).

Важно (проверено): `rake game:*` пересоздаёт базу. Список стран нигде не «включается»: после сидирования можно работать за любое государство. У государств, для которых seeds не создают знать или гильдии, экраны будут пустыми (ошибок нет) — данные появляются, как только за страну начинают играть.

---

## 11. Миграция существующих данных и обратная совместимость

Порядок наката на работающую базу:

1. `rails db:migrate` — добавляет поля без блокировок, значения `NULL`.
2. Бэкфилл (однократная задача `rails many_teams:backfill` или `rails runner`):

```ruby
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

3. Готово: страна по умолчанию — «Русь», отдельного признака играбельности нет и проставлять нечего.

Ожидаемый результат бэкфилла — поведение, идентичное текущему:

- `Country.current` = «Русь» (страна по умолчанию), значит `Country#relations` = сегодняшнее значение;
- `players.country_id = РУС` — совет, влияние, доход резолвятся как сейчас;
- `technology_items.country_id = РУС` — открытие технологий идёт в ту же строку, что и раньше;
- `political_actions.country_id = РУС` — «выполнено в этом году» считается как сейчас;
- в шапке можно выбрать любое государство, по умолчанию подставлена «Русь», поэтому вид экранов совпадает с прежним, а Дашборд показывает «Русь» и остальные страны.

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

1. Pre-check перед миграцией 4:

```ruby
TechnologyItem.group(:technology_id).having("count(*) > 1").count  # должно быть пусто
```

2. Пост-проверка бэкфилла:

```ruby
Player.where(country_id: nil).count           # 0
TechnologyItem.where(country_id: nil).count   # 0
PoliticalAction.where(country_id: nil).count  # 0
TechnologyItem.group(:country_id).count.size # 12 — по строке на каждое государство
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

Расхождение допустимо только в новых полях (`country_id`, `country`, `relations_by_country`) и в количестве `technology_items` (12 → 144). Любое изменение существующих значений — дефект.

4. Сидирование (чистая база), работа за одну страну:

```
rake game:core
```

Количества совпадают с текущими, кроме технологий: 12 стран, 12 технологий, **144 `technology_items`** (12 × 12 — по строке на каждое государство), 10 должностей, столько же игроков знати, `relation_items` — по одной «ручной правке» на страну.

5. Работа за вторую страну (та же база, без пересидирования):

```ruby
TechnologyItem.group(:country_id).count.values.uniq  # [12] — у каждого государства полный набор технологий
Country.current = Country.find(Country::LITHUANIA)  # выбор любой страны работает сразу
Player.nobles.where(country_id: Country::LITHUANIA).count # по данным seeds (может быть 0)
```

Знать и гильдии заполнены у тех государств, где они есть по seeds; у остальных экраны пусты, ошибок нет.

6. Скоупы и методы:

```ruby
Country.current = Country.find(Country::RUS)
p1 = Player.nobles.first
p1.income_breakdown(Country.find(Country::RUS))[:settlements].all? { |s| s[:country_id] == Country::RUS }  # true
c = Country.find(Country::LITHUANIA)
Country.find(Country::RUS).relations_with(c) == c.relations_with(Country.find(Country::RUS))  # true (одна величина на пару)
Army.for_country(Country.find(Country::RUS)).map(&:id).sort == ...  # сверка с ручным списком
```

7. Расходы государства (Д12):

```ruby
Country.current = Country.find(Country::RUS)
county = Country.find(Country::LITHUANIA)
GameParameter.pay_state_expenses(Country.current)
Country.find(Country::RUS).state_expenses_paid?(GameParameter.current_year)  # true
county.state_expenses_paid?(GameParameter.current_year)                      # false
GameParameter.increase_year(Job::KAZNACHEI_BONUS)                            # не оплатившему — «Не оплачены расходы» в его регионах
CustomAudit.where(auditable_type: 'Country').where("comment LIKE '%госрасходы%'").count # >= 1
```

Аудит оплаты содержит год и название государства; статистика `audits#detailed_yearly_stats` отдаёт разбивку `state_expenses.by_country`.

8. Годовые результаты (Д13):

```ruby
GameParameter.show_noble_results(Country.find(Country::RUS))
  .map { |r| Player.find_by(name: r[:noble_name]).country_id }.uniq  # [Country::RUS]
GameParameter.show_sorted_results(country: Country.find(Country::RUS))
  .map { |r| Guild.find(r[:guild_id]).country_id }.uniq              # [Country::RUS]
GameParameter.snapshot_year_results(GameParameter.current_year)
GameParameter.results_for_year(1, Country.find(Country::RUS))        # снимок года и государства
```

9. Движки (Д14):

```ruby
VassalsAndRobbers::Checklist.where(sovereign_country_id: Country::RUS).count # как до миграции
VassalsAndRobbers::Checklist.where(sovereign_country_id: Country::RUS)
  .all? { |cl| cl.params.dig('vassalage', Country::RUS.to_s).present? || cl.completion_percentage >= 0 } # ключ мигрирован
Country.current = Country.find(Country::LITHUANIA)
VassalsAndRobbers::Checklist.where(sovereign_country_id: Country::LITHUANIA).count # 0 когда мастера работают за одну страну-«Руси»
ENV['ACTIVE_GAME'] = 'artel'; Resource.send_caravan(Country.current.id, [], [])    # караван от текущего государства
```

10. Паритет по расходам, результатам и движкам: до и после миграции когда мастера работают за одну страну совпадают значение флага расходов, таблицы знати/купцов (состав, места, суммы), список чек-листов с процентами выполнения, доступные места строительства.

Критерии приёмки (DoD) этапа 1:

- [ ] Все 6 миграций накатываются на копию текущей базы без потерь и откатываются (`db:rollback`).
- [ ] Бэкфилл идемпотентен (повторный прогон не меняет данные) и переводит существующую базу в состояние паритета.
- [ ] `rake game:core` (работа за одну страну) даёт данные, эквивалентные сегодняшним: сверка количеств (кроме `technology_items` — их 144) и паритет API.
- [ ] Работа за любое государство (проверка на второй стране, например Литве) даёт корректно разделённые данные (совет, технологии, отношения, политдействия, армии) без правок базы.
- [ ] `Country.current` подставляется на каждом запросе и во всех читателях, зависящих от государства; когда мастера работают за одну страну («Русь»), результат совпадает с прежним; в новых ветках логики `Country::RUS` не используется.
- [ ] Ни один существующий эндпоинт не удалён и не изменил формат существующих полей.
- [ ] Модельные валидации (игрок без страны, армия со «незнатным» владельцем-игроком, самопара отношений, дубль `technology_item`) покрыты тестами.
- [ ] Тест-план § 12 выполнен на копии боевой базы, отчёт о паритете приложен.
- [ ] Расходы государства подтверждаются по каждому государству: флаги независимы, общественный порядок и бонус Казначея начисляются тому государству, которого касаются; аудит содержит государство и год.
- [ ] Годовые результаты считаются по каждому государству (знать и купцы), снимок года сохраняется по каждому государству.
- [ ] Движки `vassals_and_robbers` и `artel` работают в разрезе текущего государства; когда мастера работают за одну страну поведение не изменилось.

---

## 13. Расходы государства (Д12): состав работ

| № | Что | Файл |
|---|---|---|
| 1 | Хэш `params['state_expenses']` по годам, методы `state_expenses_paid?` / `pay_state_expenses` / `unpay_state_expenses` | `app/models/country.rb` |
| 2 | `audited`-хук: `should_audit?` (только смена `state_expenses`) и `audit_comment` с годом и названием государства | `app/models/country.rb` |
| 3 | `pay_state_expenses(country)`, `unpay_state_expenses(country)`; из `increase_year` убрать общий флаг, добавить цикл по всем государствам (общественный порядок + бонус Казначею); ветка `state_expenses` из `should_audit?` / `audit_comment` убирается | `app/models/game_parameter.rb:5-40, 1059-1121` |
| 4 | Прокидывание `country_id` в действия оплаты; отдача состояния в `game_parameters.json` | `app/controllers/game_parameters_controller.rb:5-20`, `app/views/game_parameters/_game_parameter.json.jbuilder` |
| 5 | Статистика госрасходов по государству (`Country`-аудиты + исторические `GameParameter`-аудиты), разбивка `by_country` | `app/controllers/audits_controller.rb:350-388`, `:108-187` |
| 6 | Бэкфилл флага в `{ <current_year> => <значение> }` для «Руси» | `lib/tasks/many_teams.rake` (задача `many_teams:backfill`) |

Проверки — § 12 п. 7 и 10.

---

## 14. Годовые результаты игры (Д13): состав работ

| № | Что | Файл |
|---|---|---|
| 1 | `show_noble_results(country)`, `show_sorted_results(sort_by:, country:)`, `results_for_year(year, country)`, `results_years`, `snapshot_year_results(year, force: false)` | `app/models/game_parameter.rb:324-346, 516-575` |
| 2 | `display_results(country)`, `change_results_display(string, country)`, `get_merchant_results_settings(country)`, `update_merchant_results_settings(settings, country)` — хэши по `country_id` | `app/models/game_parameter.rb:348-403` |
| 3 | Вызов `snapshot_year_results` в `increase_year` до смены года | `app/models/game_parameter.rb:1059-1080` |
| 4 | Параметры `country_id`, `year` во всех действиях результатов; `country_id` в ответах | `app/controllers/game_parameters_controller.rb:173-260`, `config/routes.rb:55-66` |
| 5 | Фильтрация гильдий по стране при ранжировании купцов (требует `guilds.country_id`, Д11) | `app/models/game_parameter.rb:516-570` |
| 6 | Бэкфилл: скаляры `display` и настроек → хэши с ключом «Руси»; снимок текущего года выполняется один раз при выкатке | `lib/tasks/many_teams.rake` |

Проверки — § 12 п. 8 и 10.

---

## 15. Движки (Д14): состав работ и инвентарь Русь-центричных мест

### 15.1. Порядок работ

1. Миграция 6 (`engines/vassals_and_robbers/db/migrate/`): `sovereign_country_id` + составная уникальность; бэкфилл флагов вассалитета в новый ключ.
2. `checklist.rb` — ассоциация `belongs_to :sovereign_country`, `Checklist.for_sovereign(c)`, чтение/запись флага по паре (`params['vassalage'][sov][vassal]`), `vassal_country_ids(sovereign = Country.current)`.
3. `checklist_validator.rb` — все проверки через сюзерена чек-листа (Д14.1 п. 3).
4. `checklists_controller.rb` — выборка по сюзерену, `sovereign_country` в ответе.
5. `political_action_extensions.rb`, `player_extensions.rb`, `plant_places_controller_extensions.rb` — `Country::RUS` → `Country.current` (Д14.1 пп. 4–7).
6. Seeds движка — `sovereign_country_id`, суммы вассальных доходов по сюзеренам, чек-листы для каждого государства.
7. `engines/artel/**` — контекст текущего государства (Д14.2), включая `Resource`.

### 15.2. Инвентарь (файл:строка → как должно быть)

| Файл:строка | Сейчас | Стало |
|---|---|---|
| `vassals_and_robbers/app/services/.../checklist_validator.rb:69` | `rus = Country.find_by(id: Country::RUS)` для проверки союза | союз с сюзереном чек-листа |
| `.../checklist_validator.rb:40-56` | мощь армии — все игроки типа «Знать» | знать сюзерена чек-листа |
| `.../checklist_validator.rb:36-57, 99-130` | отношения/товарооборот — `target_country.relations` / `show_current_trade_level` (неявно с «Русью») | с сюзереном чек-листа |
| `.../checklist_validator.rb:132-150` | технологии — `tech.is_open != 1` (глобальный флаг) | `is_open(сюзерен)` |
| `.../checklist_validator.rb:152-200` | предприятия/строения/общественный порядок — по всей базе/по региону | по владениям и регионам сюзерена |
| `.../checklist.rb:8, 22-33, 41-48` | уникальность по `vassal_country_id`, флаг `vassal_<id>_established` | составная уникальность, флаг по паре |
| `.../concerns/political_action_extensions.rb:121, 144, 175` | регионы и союз «Руси» | текущее государство |
| `.../concerns/player_extensions.rb:17-45` | доход от вассалов у любого Казначея | у Казначея своего государства |
| `.../controllers/concerns/plant_places_controller_extensions.rb:15-16, 44` | `[Country::RUS] + вассалы`, `is_open` глобально | текущее государство + его вассалы, `is_open(Country.current)` |
| `.../checklists_controller.rb:6-45, 60-95` | все чек-листы, флаг по одиночному ключу | чек-листы текущего сюзерена, флаг по паре |
| `.../db/seeds/0_vassalage_settings.rb` | `vassal_incomes` — плоский хэш | по сюзеренам |
| `.../db/seeds/2_vassal_checklists.rb` | чек-листы без сюзерена | `sovereign_country_id` = государства из seeds |
| `artel/app/controllers/concerns/plant_places_controller_extensions.rb:14` | `Technology.find_by(id: Technology::CRAFTSMEN).is_open` | `is_open(Country.current)` |
| `artel/app/controllers/concerns/plants_controller_extensions.rb:12-20` | владелец — любая гильдия | гильдия текущего государства |
| `artel/app/models/artel/concerns/plant_extensions.rb:12-20` | проверка только типа владельца | то же + проверка государства гильдии |
| `artel/app/models/artel/concerns/resource_extensions.rb:20-95` | `country_id = nil` / `ENV['ACTIVE_GAME']`-ветки, ключ уровня `0` | контекст текущего государства, уровень — по паре отношений |
| `app/controllers/plant_places_controller.rb:57` | `belongs_to_rus = region&.country_id == Country::RUS` | `== Country.current.id` |

Проверки — § 12 п. 9 и 10.

---

## 16. Риски и ограничения

| Риск | Оценка | Что делаем |
|---|---|---|
| Смена семантики `relations` (одна величина «страна → Русь» → пара) задевает читателей: цены ресурсов (`app/models/resource.rb:92-112, 145-152`), союзы (`app/views/countries/_country.json.jbuilder:18-38`), бонус «Третий Рим» | Высокий | Читатели остаются на алиасе `relations` с дефолтным партнёром = текущее государство; переход на `relations_with(partner)` — этап 2, по списку мест (приложение А, п. 5) |
| Уникальный индекс `technology_items(technology_id, country_id)` не накатится из-за дублей | Средний | Pre-check § 12 п. 1, дубли разбираются вручную/склейкой значений |
| Seeds не идемпотентны (повторный `db:seed:all` без drop дублирует записи) | Средний | В новых seed-файлах только `find_or_create_by`; полный перезапуск игры — `rake game:core` (пересоздание базы) |
| Миграция движка (6) в `engines/vassals_and_robbers/db/migrate` идёт общей задачей: при неверном порядке наката чек-листы останутся без сюзерена | Средний | Сюзерен nullable + бэкфилл «Русь» сразу после миграции; pre-check дублей и самопар (§ 15.1 п. 1) |
| Аудит оплаты расходов переезжает с `GameParameter` на `Country`: историческая статистика может «потеряться» | Средний | `get_state_expenses_stats` читает оба источника + разбивка по государству |
| Снимок годовых результатов растёт в `params` записи `results` | Низкий | Компактные срезы на государство, ограничение по числу лет игры; при необходимости выносится в отдельную таблицу (вопрос Q7) |
| `ACTIVE_GAME=artel` — отдельный режим игры, легко забыть в проверках | Средний | Тест-план § 12 пп. 9–10 выполняется в обоих режимах |
| Смешение «снимка» и «живого» расчёта результатов в интерфейсе | Низкий | В API явно отдаётся `year` и признак источника (`live` / `snapshot`) |
| Мастер по привычке работает «за Русь», когда команд несколько | Низкий | Текущее государство всегда видно в шапке; переключатель рядом с выбором мастера |
| Долгий бэкфилл на большой базе (12 стран/игроки — тысячи строк) | Низкий | `update_all` + `find_each`, офлайн-окно перед игрой |

---

## 17. Открытые вопросы (нужны решения заказчика)

- **Q1 (Д3, ключевой).** Знатный совет: подтверждаем вариант A — справочник 10 должностей общий, «свой совет» = свои игроки государства на этих должностях? Или нужны отдельные строки должностей на государство (вариант B) со своим набором политдействий на каждое государство? Рекомендация — A.
- **Q2 (Д4).** Отношения — одна величина на пару государств (не направленная)? Рекомендация — да.
- **Q3 (Д10, Д11).** Торговые очки: делаем их парными (страна-источник торговли ↔ страна-партнёр) и для этого заводим `guilds.country_id`? Или на этом этапе очки считаются по караванам гильдий текущего государства (меньше работы, но при нескольких командах неточно)?
- **Q4 (Д6).** Флаг получения дохода `players.params['income_taken']` оставляем один на игрока (даже если у него владения в двух государствах)? Рекомендация — да, один на игрока, как сейчас.
- **Q5.** Нужна ли мастерам «страна по умолчанию» в профиле (`users.default_country_id`), чтобы при входе сразу поднималось своё государство, или достаточно выбора в сессии?
- **Q7 (Д13).** Нужны ли снимки годовых результатов по годам (`params['by_year'][год][государство]`) или достаточно текущего ранжирования в разрезе государства? Рекомендация — снимки нужны: иначе результаты прошлого года перезаписываются текущими, и «годовые результаты» перестают быть годовыми.
- **Q8 (Д14.1).** Вассалитет: подтверждаем, что одно государство может быть вассалом только одного сюзерена (уникальность по паре `(сюзерен, вассал)`)? Рекомендация — да, как сейчас.
- **Q9 (Д13).** Результаты купцов: капитал считается по гильдиям государства (требует `guilds.country_id`, Д11) — подтверждаем? Если нет, потребуется иной признак «своей» гильдии (например, гильдия гильд-босса совета государства).

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
| `engines/vassals_and_robbers/...political_action_extensions.rb:121, 144, 175` | эффекты плагина, союз с Русью | текущее государство (Д14.1 п. 4, § 15.2) |
| `engines/vassals_and_robbers/...checklist_validator.rb:69` | сюзерен — Русь | сюзерен чек-листа (Д14.1 п. 3, § 15.2) |
| `engines/artel/...plant_places_controller_extensions.rb:16` | доступные страны = Русь + вассалы | текущее государство + его вассалы (Д14.1 п. 6, § 15.2) |

2. Константы должностей и выдачи «по должности»: `app/models/job.rb:14-30` (`Job::GRAND_PRINCE = 1` … `Job::METROPOLITAN_PINE`), перечень мест — § 8.3.

3. Технологии: `db/seeds/2_politics.rb:146-152`, `app/models/technology.rb:17-35`, чтение эффектов — `app/models/player.rb:316, 322`, `app/models/region.rb:36`, `app/models/plant_level.rb:10`, `app/controllers/plants_controller.rb:14, 18`, `app/controllers/plant_levels_controller.rb:7, 12`, `app/controllers/plant_places_controller.rb:17`, `app/views/regions/_region.json.jbuilder:12-20`, `app/views/technologies/_technology.json.jbuilder:1-4`.

4. Влияние/доход: `influence_items.player_id`, `income_items.player_id`, `players.params['income_taken']`, сброс флага в `app/models/game_parameter.rb:1084-1089`, аудит получения дохода `app/models/player.rb:7-18, 486-503`.

5. Читатели отношений: `app/models/resource.rb:92-93, 110-112, 145-152` (цены по уровню отношений), `app/views/countries/_country.json.jbuilder:6-38` (значение, элементы, союзы «Руси»), `era_front/src/views/dashboard/Relations.vue:12-120` (правки и очки), `app/models/country.rb:184-290` (начисление очков по товарообороту), `db/seeds/3_resources_and_countries.rb` (базовые отношения стран).

6. Расходы, результаты и движки (в объёме этого ТЗ — детальный инвентарь в § 15.2 и § 13–14):
   - расходы государства: `GameParameter#pay_state_expenses` / `unpay_state_expenses` (`app/models/game_parameter.rb:1108-1123`), `increase_year` (`:1059-1080`), аудит (`:5-40`), статистика (`app/controllers/audits_controller.rb:350-388`);
   - годовые результаты: `app/models/game_parameter.rb:324-346, 348-403, 405-577` (знать, настройки экрана, купцы), `app/controllers/game_parameters_controller.rb:173-260`, `config/routes.rb:55-66`;
   - движки: `engines/vassals_and_robbers/**` (чек-листы, валидатор, союзы, доход вассалов, доступные места строительства), `engines/artel/**` (технологии, ресурсы, предприятия гильдий).
7. Остаётся вне объёма: мобильные эндпоинты (`config/routes.rb:36-52`) и мобильные экраны движков.
