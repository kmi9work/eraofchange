# ТЗ № 1. Этап 1 «структура данных»: что внедрено и как проверено

Документ фиксирует состав работ по `docs/many_teams/TZ-1-struktura-dannyh.md`,
порядок выкатки и результаты проверок (§ 12 ТЗ).

## 1. Состав изменений

Схема БД (6 миграций, все столбцы `null: true`, обязательность — дефолтом в модели):

| Миграция | Что делает |
|---|---|
| `db/migrate/20261016120001_add_country_to_players.rb` | `players.country_id` |
| `db/migrate/20261016120002_add_country_to_guilds.rb` | `guilds.country_id` |
| `db/migrate/20261016120003_add_partner_country_to_relation_items.rb` | `relation_items.partner_country_id` |
| `db/migrate/20261016120004_add_country_to_technology_items.rb` | `technology_items.country_id` + уникальный индекс `(technology_id, country_id)` |
| `db/migrate/20261016120005_add_country_to_political_actions.rb` | `political_actions.country_id` |
| `engines/vassals_and_robbers/db/migrate/20261016120006_add_sovereign_country_to_vassals_and_robbers_checklists.rb` | `sovereign_country_id`, уникальность пары «сюзерен × вассал», бэкфилл сюзерена в «Русь», перенос флага `vassal_<id>_established` в `params['vassalage'][<страна>]` |

Модели: `Country` (ассоциации, `Country.current`/`Country.resolve`, отношения парами,
расходы по годам, аудит оплаты), `Player`, `Guild`, `Army`, `Region`, `Settlement`,
`PublicOrderItem`, `Job`, `Building`, `Caravan`, `Technology`, `TechnologyItem`,
`RelationItem`, `PoliticalAction`, `GameParameter` (снимки года и ранжирование по
государствам, оплата расходов за государство).

Контроллеры и представления: `application` (`current_country` из `session[:country_id]`),
`countries` (фильтры, `/current_country`, `/login_country/:id`), `players`, `regions`,
`settlements`, `technologies`, `technology_items`, `armies`, `jobs`,
`political_actions`, `game_parameters` (разрез расходов), `audits` (статистика по
государствам), `plant_places`, плюс jbuilder-шаблоны этих ресурсов.

Движки: `vassals_and_robbers` (`Checklist` с явным сюзереном, `VassalageSettings`,
`ChecklistValidator`, контроллер чек-листов, расширения игрока/политдействий/мест
строительства, сиды) и `artel` (разрезы по текущему государству в ценах, владельцах
предприятий и местах строительства).

Сиды: `db/seeds/1_players.rb`, `2_politics.rb`, `5_economics.rb`,
`engines/artel/db/seeds/0_economics.rb` (гильдии с государством),
новый `db/seeds/9_1_countries.rb` — идемпотентная привязка «осиротевших» записей к
«Руси». Файл назван `9_1_countries.rb`, а не `1_1_countries.rb` из ТЗ: seeds
загружаются по алфавиту (`lib/tasks/custom_seed.rake`), и `1_1_...` выполнился бы
раньше `1_players.rb`.

## 2. Порядок выкатки

```
bin/rails db:migrate        # 6 миграций, только добавление столбцов/индексов
bin/rails many_teams:precheck   # дубли technology_items перед миграцией 4
bin/rails many_teams:backfill   # бэкфилл: NULL → «Русь», скаляры → хэши, снимок года
bin/rails many_teams:report     # что осталось без государства, состояние по странам
bin/rails many_teams:verify     # проверки § 12 по текущей базе (только чтение)
```

Чистая база (без выкатки на существующую): `rake game:core`, затем
`rake game:vassals` / `rake game:artel` — новые столбцы заполняются сидами.

`many_teams:backfill` идемпотентен: заполняются только пустые значения, повторный
прогон не меняет данные. Значения, введённые явно, не перезаписываются.
`many_teams:verify` по умолчанию ничего не меняет; оплата госрасходов и смена года
включаются `MUTATING=1` (только на копии базы).

## 3. Результаты проверок

Как запускать тесты (в репозитории раздел `test:` в `config/database.yml` закомментирован,
поэтому тестовая база задаётся через `DATABASE_URL`):

```
createdb -U deploy era_many_teams_test
RAILS_ENV=test DATABASE_URL=postgres://<логин>:<пароль>@<хост>/era_many_teams_test bin/rails db:schema:load
RAILS_ENV=test DATABASE_URL=postgres://<логин>:<пароль>@<хост>/era_many_teams_test \
  bin/rails test test/models/many_teams_test.rb
```

1. Модельные тесты: `bin/rails test test/models/many_teams_test.rb` — 22 теста,
   108 утверждений, 0 провалов (валидации игрока без страны, армии со «незнатным»
   владельцем, самопары отношений, дубля `technology_item`; разрезы по государствам:
   совет, расходы, результаты, вассалитет; легаси-ключи).
2. Миграции: накат всех миграций на пустую базу, `db:rollback STEP=6` (6 наших
   откатились, остаётся только прежний `relation_items.country_id`), повторный накат —
   состояние восстанавливается, `db:migrate:status` — все `up`.
3. Свежее сидирование (`game:core` + движки) и `many_teams:verify`: все проверки § 12
   пройдены. Значения счётчиков: 12 стран, 9 технологий (см. п. 4),
   108 = 9 × 12 строк `technology_items`, по полному набору у каждого государства,
   0 записей без государства, 0 самопар отношений, у второго государства — пустые
   экраны совета/гильдий без ошибок.
4. Боевая копия базы (разработческая) после миграций и бэкфилла: `many_teams:verify`
   — все проверки пройдены; `many_teams:backfill` повторно не меняет данные.
5. Паритет API: `docs/many_teams/api_parity_check.py` (26 проверок) — все эндпоинты
   отвечают 200, старые поля не изменились, новые поля (`country_id`, `country`,
   `relations_by_country`, `state_expenses_by_country`) добавлены. Расхождения только
   в ожидаемых местах; `technology_items` выросли с 9 до 108 (технологий 9 × стран 12).
6. Расходы/год/движки: флаги расходов независимы по государствам, аудит содержит год и
   название государства, смена года делает снимок по каждому государству и начисляет
   «Не оплачены расходы» только неоплатившим; чек-листы вассалитета читаются по паре
   «сюзерен × вассал» (5 чек-листов «Руси», у второго государства — пусто).

## 4. Отклонения и оговорки

1. В сейвах репозитория 9 технологий и 9 должностей (в ТЗ — 12 и 10). Это состояние
   сидов, а не следствие перехода: счётчики `technology_items` в ТЗ (144 = 12 × 12)
   получаются умножением фактического числа технологий на число государств.
2. Заготовки тестов репозитория (`test/fixtures/*.yml`, сгенерированные каркасом)
   не соответствуют схеме: `armies.yml` ссылается на столбцы `region`/`player`/
   `army_size`, `caravans.yml` — на `title`/`body`, часть фикстур — на удалённые
   таблицы. Из-за этого весь набор (272 теста) падает при загрузке фикстур ещё до
   выполнения кода — и до перехода тоже. Тесты ТЗ № 1 сделаны самодостаточными
   (`self.fixture_table_names = []`) и проходят независимо.
3. Легаси-ветки совместимости (записи без государства, ключ
   `params['vassal_<id>_established']`, скалярные `relation_points`/
   `last_trade_turnover`) намеренно опираются на `Country::RUS`. Это чтение старых
   данных, новых игровых веток на `Country::RUS` нет.
4. Самопара «Русь — Русь» в `relation_items` не хранится: у собственной записи
   отношений «Руси» второй конец пуст (так делают и сиды, и бэкфилл).

## 5. Откат

```
bin/rails db:rollback STEP=6      # снять 6 миграций (столбцы удаляются)
```
Откат удаляет привязку записей к государствам и партнёров отношений; данные,
заполненные бэкфиллом, после повторного наката восстанавливаются прогоном
`bin/rails many_teams:backfill` (кроме снимка года — он идемпотентен и не
перетирает уже сохранённые срезы).
