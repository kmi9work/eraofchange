<!-- EXAMPLE: Это шаблонный файл для создания своего Engine -->
# Vassals and Robbers Engine

Rails Engine для функционала игры "Vassals and Robbers"

## Описание

Этот Engine расширяет функционал основного приложения Era of Change, добавляя механики для игры "Vassals and Robbers".

## Установка

### 1. Подключение Engine

Добавьте в Gemfile основного приложения:

```ruby
gem 'vassals_and_robbers', path: 'engines/vassals_and_robbers'
```

### 2. Установка зависимостей

```bash
cd eraofchange
bundle install
```

### 3. Запуск миграций

Engine содержит свои миграции в `db/migrate/` и они запускаются **напрямую без копирования** в основное приложение.

```bash
# Запуск всех миграций (включая миграции Engine)
rails db:migrate

# Проверка статуса миграций (включая Engine)
rails db:migrate:status

# Откат последней миграции
rails db:rollback
```

**Важно:** Миграции плагина остаются в `engines/vassals_and_robbers/db/migrate/` и выполняются вместе с миграциями ядра благодаря настройке в `engine.rb`.

### 4. Загрузка начальных данных (Seeds)

Engine имеет свои seed файлы в `db/seeds/`. Чтобы загрузить их:

```bash
# Загрузить все seeds плагина
rake vassals_and_robbers:db:seed:all

# Загрузить конкретный seed файл (например, 0_example_seed)
rake vassals_and_robbers:db:seed:0_example_seed
```

**Структура seeds:**
- Seed файлы находятся в `engines/vassals_and_robbers/db/seeds/`
- Используйте числовые префиксы (0_, 1_, 2_) для контроля порядка загрузки
- Файлы загружаются в алфавитном порядке

**Пример seed файла:**

```ruby
# db/seeds/0_vassals.rb
puts "Creating vassals..."

VassalsAndRobbers::Vassal.create(
  name: "Боярин Иван",
  loyalty: 75,
  player_id: 1,
  country_id: 1
)

puts "Vassals created!"
```

## Использование

### Активация игры

Установите переменную окружения:

```bash
ACTIVE_GAME=vassals_and_robbers rails server
```

### Расширение моделей ядра

Engine автоматически расширяет модели ядра через concerns:

```ruby
# Модель Plant будет расширена через VassalsAndRobbers::Concerns::PlantExtensions
# Модель Country будет расширена через VassalsAndRobbers::Concerns::CountryExtensions
```

Вы можете добавлять свои методы в файлы:
- `app/models/vassals_and_robbers/concerns/plant_extensions.rb`
- `app/models/vassals_and_robbers/concerns/country_extensions.rb`

## Структура Engine

```
engines/vassals_and_robbers/
├── app/
│   ├── controllers/        # Контроллеры игры
│   ├── models/
│   │   └── concerns/       # Расширения моделей ядра
│   ├── services/           # Сервисы бизнес-логики
│   ├── helpers/            # Helper методы
│   └── assets/             # CSS и JS
├── config/
│   └── routes.rb           # Маршруты Engine
├── db/
│   ├── migrate/            # Миграции Engine
│   └── seeds/              # Seed файлы Engine
├── lib/
│   ├── tasks/              # Rake задачи
│   └── vassals_and_robbers/
│       ├── engine.rb       # Определение Engine
│       └── version.rb      # Версия
└── test/                   # Тесты
```

## Разработка

### Создание миграций

#### Автоматическое создание с timestamp

Используйте rake задачу для создания миграции с правильным timestamp префиксом:

```bash
# Создать новую миграцию
rake vassals_and_robbers:db:create_migration[create_vassals_table]

# Или с другим именем
rake vassals_and_robbers:db:create_migration[add_status_to_vassals]
```

Эта команда создаст файл вида: `20251029092837_create_vassals_table.rb` в `engines/vassals_and_robbers/db/migrate/`

#### Ручное создание

1. Создайте файл в `db/migrate/` с timestamp префиксом: `YYYYMMDDHHMMSS_migration_name.rb`
2. **Обязательно используйте namespace** для таблиц: `vassals_and_robbers_table_name`
3. Запустите миграции: `rails db:migrate`

**Важно:** 
- Используйте текущий timestamp для новых миграций
- Всегда префикс таблиц: `vassals_and_robbers_`
- Миграции запускаются напрямую из Engine, без копирования

**Пример миграции:**

```ruby
# engines/vassals_and_robbers/db/migrate/20251029092837_create_vassals_and_robbers_vassals.rb
class CreateVassalsAndRobbersVassals < ActiveRecord::Migration[7.0]
  def change
    create_table :vassals_and_robbers_vassals do |t|
      t.string :name, null: false
      t.integer :loyalty, default: 50
      t.references :player, foreign_key: true
      t.references :country, foreign_key: true
      t.jsonb :params, default: {}
      
      t.timestamps
    end
    
    add_index :vassals_and_robbers_vassals, :loyalty
    add_index :vassals_and_robbers_vassals, :name
  end
end
```

### Создание seed файлов

1. Создайте файл в `db/seeds/` с числовым префиксом
2. Используйте `puts` для вывода информации о процессе
3. Загрузите seeds: `rake vassals_and_robbers:db:seed:all`

### Откат миграций

```bash
# Откатить последнюю миграцию
rails db:rollback

# Откатить определённое количество миграций
rails db:rollback STEP=3

# Откатить конкретную миграцию
rails db:migrate:down VERSION=20231029120000
```

## Полезные команды

### Миграции

```bash
# Создать новую миграцию для плагина
rake vassals_and_robbers:db:create_migration[migration_name]

# Проверить статус всех миграций (включая плагин)
rails db:migrate:status

# Запустить миграции (ядра и плагина вместе)
rails db:migrate

# Откатить последнюю миграцию
rails db:rollback

# Откатить несколько миграций
rails db:rollback STEP=3

# Откатить конкретную миграцию по VERSION
rails db:migrate:down VERSION=20251029092837
```

### Seeds

```bash
# Загрузить только seeds основного приложения
rails db:seed

# Загрузить все seeds плагина
rake vassals_and_robbers:db:seed:all

# Загрузить конкретный seed файл
rake vassals_and_robbers:db:seed:0_example_seed
```

### База данных

```bash
# Пересоздать БД с миграциями и seeds ядра
rails db:reset

# Полный цикл: удалить, создать, мигрировать
rails db:drop db:create db:migrate

# Загрузить seeds ядра + плагина
rails db:seed && rake vassals_and_robbers:db:seed:all
```

### Информация

```bash
# Список всех доступных задач плагина
rake -T vassals_and_robbers

# Список всех задач по работе с БД
rake -T db
```

## TODO

- [ ] Добавить контроллеры для игровой логики
- [ ] Добавить модели для сущностей игры
- [ ] Создать миграции для таблиц БД
- [ ] Создать seed файлы с начальными данными
- [ ] Реализовать бизнес-логику в concerns
- [ ] Добавить тесты
- [ ] Добавить документацию API

