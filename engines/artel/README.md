# Artel Engine

Rails Engine для функциональности игры Artel (ресурсы без привязки к стране, один уровень отношений, предприятия гильдий).

## Установка

Добавьте в `Gemfile` главного приложения:

```ruby
gem 'artel', path: 'engines/artel'
```

Затем выполните:

```bash
bundle install
```

## Использование

### Миграции

Миграции плагина находятся в `engines/artel/db/migrate/` и выполняются вместе с миграциями ядра. Иконки для типов предприятий, категорий и гильдий добавляются миграцией в ядре (`add_icon_to_plant_types_guilds_and_plant_categories`).

### Сиды

Сиды движка лежат в `engines/artel/db/seeds/`. Используются Rake-задачи из главного приложения:

- **Только сиды Artel** (база и базовые сиды уже накатаны):
  ```bash
  bundle exec rake db:seed:artel
  ```

- **Полная пересборка БД под игру Artel** (drop, create, migrate, базовые сиды, затем сиды Artel):
  ```bash
  bundle exec rake game:artel
  ```

При `game:artel` выставляются `ENV['ACTIVE_GAME']=artel` и `ENV['APP_VERSION']=artel`.

### Запуск приложения

Установите переменную окружения:

```bash
ACTIVE_GAME=artel rails server
```

## API и иконки

- **Ресурсы**: в JSON возвращается `icon_url` по конвенции `/images/resources/#{identificator}.png`. Фронт может подставлять `identificator` и показывать иконку.
- **Типы предприятий (PlantType)**: в API есть поле `icon` (например класс Remix Icon) и `icon_url` — конвенция `/images/plant_types/#{id}.png`.
- **Категории предприятий (PlantCategory)**: `icon` и `icon_url` — `/images/plant_categories/#{id}.png`.
- **Гильдии (Guild)**: `icon` и `icon_url` — `/images/guilds/#{id}.png`.

В сидах Artel для категорий и типов предприятий заданы иконки Remix Icon (поле `icon`). При необходимости можно положить PNG по путям выше.

## Локализация

Названия ресурсов и предприятий заданы в сидах. При необходимости можно вынести их в локали (например `config/locales/artel.ru.yml` в движке) и использовать `I18n.t` в API или фронте.

## Структура

```
engines/artel/
├── app/
│   ├── controllers/concerns/
│   ├── models/artel/concerns/
│   └── ...
├── config/
│   └── routes.rb
├── db/
│   └── seeds/
│       └── 0_economics.rb   # ресурсы, гильдии, контракты, предприятия
└── lib/
    └── artel/
        ├── engine.rb
        └── version.rb
```

## Зависимости сидов

Сид `0_economics.rb` создаёт ресурсы (country_id: nil), гильдии, категории предприятий, типы предприятий и уровни. Для полного сценария «игра Artel» обычно сначала выполняют базовые сиды приложения (игроки, параметры игры и т.д.), затем `db:seed:artel`. Задача `game:artel` делает это автоматически.