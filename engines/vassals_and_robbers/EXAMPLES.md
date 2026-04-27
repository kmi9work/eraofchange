<!-- EXAMPLE: Это шаблонный файл для создания своего Engine -->
# Примеры использования Vassals and Robbers Engine

## Расширение моделей ядра через Concerns

### Пример 1: Добавление методов в модель Plant

```ruby
# app/models/vassals_and_robbers/concerns/plant_extensions.rb
module VassalsAndRobbers
  module Concerns
    module PlantExtensions
      extend ActiveSupport::Concern

      included do
        # Добавляем связь с вассалами
        has_many :vassal_assignments,
                 class_name: 'VassalsAndRobbers::VassalAssignment',
                 dependent: :destroy
        
        # Scope для предприятий под контролем вассалов
        scope :controlled_by_vassals, -> {
          joins(:vassal_assignments).where('vassal_assignments.active = ?', true)
        }
        
        # Callback для инициализации параметров игры
        after_create :initialize_vassals_params, if: :vassals_game_active?
      end

      # Методы экземпляра
      def assign_to_vassal(vassal)
        vassal_assignments.create!(vassal: vassal, assigned_at: Time.current, active: true)
      end

      def under_vassal_control?
        vassal_assignments.where(active: true).exists?
      end

      def collect_vassal_tribute
        return 0 unless under_vassal_control?
        
        tribute_amount = calculate_tribute
        # Логика сбора дани
        tribute_amount
      end

      private

      def vassals_game_active?
        ENV['ACTIVE_GAME'] == 'vassals_and_robbers'
      end

      def initialize_vassals_params
        self.params ||= {}
        self.params['vassals_and_robbers'] = {
          'tribute_collected' => 0,
          'last_tribute_date' => nil
        }
        save
      end

      def calculate_tribute
        # Ваша логика расчёта дани
        100
      end

      # Class methods
      class_methods do
        def total_tribute_collected
          where.not("params -> 'vassals_and_robbers' ->> 'tribute_collected' IS NULL")
               .sum("(params -> 'vassals_and_robbers' ->> 'tribute_collected')::integer")
        end
      end
    end
  end
end
```

### Пример 2: Расширение модели Country

```ruby
# app/models/vassals_and_robbers/concerns/country_extensions.rb
module VassalsAndRobbers
  module Concerns
    module CountryExtensions
      extend ActiveSupport::Concern

      included do
        # Связь с вассалами страны
        has_many :vassals,
                 class_name: 'VassalsAndRobbers::Vassal',
                 dependent: :destroy
        
        # Scope для стран с вассалами
        scope :with_vassals, -> { joins(:vassals).distinct }
      end

      # Подсчёт общей лояльности вассалов
      def total_vassal_loyalty
        vassals.sum(:loyalty)
      end

      # Средняя лояльность вассалов
      def average_vassal_loyalty
        vassals.average(:loyalty).to_f.round(2)
      end

      # Проверка на наличие мятежных вассалов
      def has_rebellious_vassals?
        vassals.where('loyalty < ?', 30).exists?
      end
    end
  end
end
```

## Создание моделей плагина

### Пример: Модель Vassal

```ruby
# app/models/vassals_and_robbers/vassal.rb
module VassalsAndRobbers
  class Vassal < ApplicationRecord
    # Указываем имя таблицы с namespace плагина
    self.table_name = 'vassals_and_robbers_vassals'

    # Используем audited из ядра
    audited

    # Связи с моделями ядра (используем ::)
    belongs_to :player, class_name: '::Player'
    belongs_to :country, class_name: '::Country'
    
    # Связи внутри плагина
    has_many :vassal_assignments, dependent: :destroy
    has_many :plants, through: :vassal_assignments, source: :plant

    # Валидации
    validates :name, presence: true
    validates :loyalty, numericality: { 
      greater_than_or_equal_to: 0, 
      less_than_or_equal_to: 100 
    }

    # Enum для статусов
    enum status: {
      loyal: 0,
      neutral: 1,
      rebellious: 2
    }

    # Scopes
    scope :loyal_vassals, -> { where('loyalty >= ?', 70) }
    scope :rebellious_vassals, -> { where('loyalty < ?', 30) }

    # Методы
    def increase_loyalty(amount)
      update(loyalty: [loyalty + amount, 100].min)
    end

    def decrease_loyalty(amount)
      update(loyalty: [loyalty - amount, 0].max)
    end

    def collect_tribute
      total = 0
      plants.each do |plant|
        total += plant.collect_vassal_tribute
      end
      total
    end
  end
end
```

## Создание контроллеров

### Пример: VassalsController

```ruby
# app/controllers/vassals_and_robbers/vassals_controller.rb
module VassalsAndRobbers
  class VassalsController < ApplicationController
    before_action :set_vassal, only: [:show, :update, :destroy, :collect_tribute]

    def index
      @vassals = Vassal.includes(:player, :country).all
      render json: @vassals
    end

    def show
      render json: @vassal.as_json(
        include: {
          player: { only: [:id, :name] },
          country: { only: [:id, :name] },
          plants: { only: [:id, :plant_level_id] }
        }
      )
    end

    def create
      @vassal = Vassal.new(vassal_params)
      
      if @vassal.save
        render json: @vassal, status: :created
      else
        render json: { errors: @vassal.errors }, status: :unprocessable_entity
      end
    end

    def update
      if @vassal.update(vassal_params)
        render json: @vassal
      else
        render json: { errors: @vassal.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      @vassal.destroy
      head :no_content
    end

    # Кастомное действие
    def collect_tribute
      tribute = @vassal.collect_tribute
      
      render json: {
        success: true,
        tribute_collected: tribute,
        vassal: @vassal
      }
    end

    private

    def set_vassal
      @vassal = Vassal.find(params[:id])
    end

    def vassal_params
      params.require(:vassal).permit(:name, :loyalty, :status, :player_id, :country_id)
    end
  end
end
```

## Маршруты

```ruby
# config/routes.rb
VassalsAndRobbers::Engine.routes.draw do
  resources :vassals do
    member do
      post :collect_tribute
      patch :increase_loyalty
      patch :decrease_loyalty
    end
  end

  resources :robbers do
    member do
      post :raid
      patch :defeat
    end
  end
end
```

## Seeds

### Пример seed файла

```ruby
# db/seeds/0_vassals.rb
puts "Creating vassals for Vassals and Robbers..."

# Убедимся, что игроки и страны существуют
player = Player.first || Player.create(name: "Тестовый игрок")
country = Country.find_by(id: Country::RUS) || Country.first

# Создаём вассалов
vassals_data = [
  { name: "Боярин Иван Грозный", loyalty: 85, status: :loyal },
  { name: "Князь Дмитрий Храбрый", loyalty: 70, status: :loyal },
  { name: "Воевода Петр Смутьян", loyalty: 45, status: :neutral },
  { name: "Боярин Василий Предатель", loyalty: 20, status: :rebellious }
]

vassals_data.each do |data|
  VassalsAndRobbers::Vassal.find_or_create_by(name: data[:name]) do |vassal|
    vassal.loyalty = data[:loyalty]
    vassal.status = data[:status]
    vassal.player = player
    vassal.country = country
  end
end

puts "Vassals created: #{VassalsAndRobbers::Vassal.count}"
```

## Миграции

### Создание миграции

```bash
# Использование rake задачи (рекомендуется)
rake vassals_and_robbers:db:create_migration[create_vassals_and_robbers_vassals]

# Это создаст файл с timestamp префиксом:
# engines/vassals_and_robbers/db/migrate/20251029092837_create_vassals_and_robbers_vassals.rb
```

### Пример миграции для создания таблицы

```ruby
# db/migrate/20251029092837_create_vassals_and_robbers_vassals.rb
class CreateVassalsAndRobbersVassals < ActiveRecord::Migration[7.0]
  def change
    create_table :vassals_and_robbers_vassals do |t|
      t.string :name, null: false
      t.integer :loyalty, default: 50, null: false
      t.integer :status, default: 0, null: false
      t.references :player, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true
      t.jsonb :params, default: {}

      t.timestamps
    end

    add_index :vassals_and_robbers_vassals, :loyalty
    add_index :vassals_and_robbers_vassals, :status
    add_index :vassals_and_robbers_vassals, :name
  end
end
```

### Пример миграции для связующей таблицы

```ruby
# db/migrate/20251029093015_create_vassals_and_robbers_vassal_assignments.rb
class CreateVassalsAndRobbersVassalAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :vassals_and_robbers_vassal_assignments do |t|
      t.references :vassal, null: false, foreign_key: { to_table: :vassals_and_robbers_vassals }
      t.references :plant, null: false, foreign_key: true
      t.boolean :active, default: true
      t.datetime :assigned_at
      t.datetime :revoked_at

      t.timestamps
    end

    add_index :vassals_and_robbers_vassal_assignments, [:vassal_id, :plant_id], 
              unique: true, 
              name: 'index_vassal_assignments_on_vassal_and_plant'
    add_index :vassals_and_robbers_vassal_assignments, :active
  end
end
```

### Запуск миграций

```bash
# Миграции Engine запускаются вместе с миграциями ядра
rails db:migrate

# Проверка статуса (увидите миграции и ядра и плагина)
rails db:migrate:status

# Откат миграции
rails db:rollback
```

**Важно:** 
- Миграции остаются в `engines/vassals_and_robbers/db/migrate/`
- Не копируются в основное приложение
- Запускаются напрямую благодаря настройке в `engine.rb`

## Использование в консоли Rails

```ruby
# Запуск консоли
rails console

# Создание вассала
vassal = VassalsAndRobbers::Vassal.create(
  name: "Боярин Тест",
  loyalty: 75,
  player_id: 1,
  country_id: 1
)

# Использование расширенных методов Plant
plant = Plant.first
plant.assign_to_vassal(vassal)
plant.under_vassal_control? # => true
plant.collect_vassal_tribute # => 100

# Использование расширенных методов Country
country = Country.first
country.total_vassal_loyalty # => 150
country.average_vassal_loyalty # => 75.0
```

## Тестирование

```ruby
# test/models/vassals_and_robbers/vassal_test.rb
require 'test_helper'

module VassalsAndRobbers
  class VassalTest < ActiveSupport::TestCase
    test "should create vassal with valid attributes" do
      vassal = Vassal.new(
        name: "Test Vassal",
        loyalty: 80,
        player_id: players(:one).id,
        country_id: countries(:rus).id
      )
      
      assert vassal.valid?
      assert vassal.save
    end

    test "should not create vassal without name" do
      vassal = Vassal.new(loyalty: 80)
      assert_not vassal.valid?
      assert_includes vassal.errors[:name], "can't be blank"
    end

    test "should increase loyalty" do
      vassal = vassals(:loyal_one)
      initial_loyalty = vassal.loyalty
      
      vassal.increase_loyalty(10)
      
      assert_equal initial_loyalty + 10, vassal.reload.loyalty
    end
  end
end
```

