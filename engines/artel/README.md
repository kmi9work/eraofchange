# Artel Engine

Rails Engine для функциональности игры Artel.

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

Миграции плагина находятся в `engines/artel/db/migrate/` и выполняются вместе с миграциями ядра.

### Seeds

Для загрузки всех seeds плагина:

```bash
rake artel:db:seed:all
```

Для загрузки конкретного seed файла:

```bash
rake artel:db:seed:0_game_parameters
```

- Seed файлы находятся в `engines/artel/db/seeds/`

## Запуск с плагином

Установите переменную окружения:

```bash
ACTIVE_GAME=artel rails server
```

## Структура

```
engines/artel/
├── app/
│   ├── controllers/
│   ├── models/
│   ├── views/
│   └── ...
├── config/
│   └── routes.rb
├── db/
│   ├── migrate/
│   └── seeds/
└── lib/
    └── artel/
        ├── engine.rb
        └── version.rb
```


