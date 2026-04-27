# Быстрый старт - Плагинная архитектура ERA

## 🚀 Запуск приложений

### Вариант 1: Интерактивный запуск

```bash
./era_scripts/start-dev.sh
```

**Вопросы:**
1. Выбор игры: `1` - base-game, `2` - vassals-and-robbers
2. Запуск mobile: `1` - да, `2` - нет

### Вариант 2: Быстрый запуск базовой игры

```bash
./era_scripts/start-base-game.sh
```

### Вариант 3: Быстрый запуск Vassals and Robbers

```bash
./era_scripts/start-vassals-game.sh
```

## 📋 Первоначальная настройка Vassals and Robbers

### 1. Установка Engine (уже выполнено)

```bash
cd eraofchange
bundle install  # Engine уже в Gemfile
```

### 2. Загрузка данных

```bash
cd eraofchange

# Сначала загрузить seeds ядра (создаёт технологии)
rake db:seed:all

# Затем загрузить seeds плагина (модифицирует технологии)
rake vassals_and_robbers:db:seed:all
```

**Вывод:**
```
Loading: .../db/seeds/0_example_seed.rb
Загрузка seeds для Vassals and Robbers...
Loading: .../db/seeds/1_update_technologies.rb
=== Vassals and Robbers: Обновление технологий ===
Удаляем технологию: Иностранные наёмники
Удаляем технологию: Кузнечное дело
Удаляем технологию: Развитая бюрократия
Обновлена технология 'Москва — Третий Рим': '+2' → '+1'
All Vassals and Robbers seeds loaded!
```

### 3. Запуск с игрой

```bash
# Вариант A: Через скрипт
./era_scripts/start-vassals-game.sh

# Вариант B: Вручную
ACTIVE_GAME=vassals-and-robbers rails server
```

## ✅ Проверка работы плагина

### Backend (Rails Console)

```bash
cd eraofchange
ACTIVE_GAME=vassals-and-robbers rails console
```

```ruby
# Проверка констант
Country.moscow_third_rome_bonus  # => 1 (вместо 2)
GameParameter.auto_start_next_cycle  # => true (вместо false)

# Проверка технологий
Technology.find_by(name: "Иностранные наёмники")  # => nil (удалена)
Technology.find_by(name: "Кузнечное дело")  # => nil (удалена)
Technology.find(6).description  # => "...+1" (было +2)

# Проверка бонуса
moscow = Technology.find(6)
moscow.open_it
Country.find(8).relations  # => 1 (вместо 2)
```

### Frontend

После запуска с игрой vassals-and-robbers:

1. Откройте страницу "Служебное" → "Экран"
2. Выберите "Таймер"
3. **Кнопка "Запустить таймер" должна быть скрыта**
4. Вместо неё: "🔄 Автоматический режим"

## 🎮 Отличия между играми

| Параметр | Base Game | Vassals and Robbers |
|----------|-----------|---------------------|
| **Технологии** | | |
| Иностранные наёмники | ✓ | ✗ Удалена |
| Кузнечное дело | ✓ | ✗ Удалена |
| Развитая бюрократия | ✓ | ✗ Удалена |
| Москва — Третий Рим (бонус) | +2 | +1 |
| **Таймер** | | |
| Запуск цикла | По кнопке | Автоматически |
| Кнопка "Запустить таймер" | Показывается | Скрыта |
| UI | Кнопка | "🔄 Автоматический режим" |

## 🔧 Технические детали

### Проверка активной игры

```bash
# Backend
ACTIVE_GAME=vassals-and-robbers rails server
ACTIVE_GAME=base-game rails server

# Проверка в консоли
ENV['ACTIVE_GAME']  # => "vassals-and-robbers" или "base-game"
```

### Переопределение констант через class_attribute

**Ядро:**
```ruby
# app/models/country.rb
class_attribute :moscow_third_rome_bonus, default: 2

# app/models/game_parameter.rb
class_attribute :auto_start_next_cycle, default: false
```

**Плагин:**
```ruby
# concerns/country_extensions.rb
included do
  self.moscow_third_rome_bonus = 1
end

# concerns/game_parameter_extensions.rb
included do
  self.auto_start_next_cycle = true
end
```

**Результат:**
- С `base-game`: используются значения по умолчанию (2, false)
- С `vassals-and-robbers`: используются переопределённые значения (1, true)

## 📚 Документация

- **Общая сводка:** `PLUGIN_ARCHITECTURE_SUMMARY.md`
- **Backend плагин:** `eraofchange/engines/vassals_and_robbers/README.md`
- **Frontend плагины:** `era_front/PLUGINS_GUIDE.md`
- **Mobile плагины:** `era_native/PLUGINS_GUIDE.md`
- **Скрипты:** `era_scripts/README.md`

## 🛠️ Команды разработки

```bash
# Миграции
rails db:migrate

# Seeds ядра
rails db:seed

# Seeds плагина
rake vassals_and_robbers:db:seed:all

# Создать миграцию плагина
rake vassals_and_robbers:db:create_migration[create_vassals_table]

# Запуск с игрой
ACTIVE_GAME=vassals-and-robbers rails server

# Или через скрипт
./era_scripts/start-vassals-game.sh
```

Готово к использованию! 🎮

