# Стоимость отрядов = полная цена постройки с нуля (решение заказчика):
#   Пехота — 50 мяса; Тяжёлая пехота — 20 металла + 70 мяса;
#   Кавалерия — 5 оружия + 30 лошадей; Пушка — 30 инструментов.
#
# Зачем миграция, если есть сид `db/seeds/4_armies.rb`: на живой базе сиды не
# перезапускаются (деплой накатывает новый релиз, а `db:seed:all` не идемпотентен
# и создал бы дубли), поэтому уже существующие строки `troop_types` нужно
# привести к новым числам отдельно. На свежей базе миграция ничего не находит —
# строки создаёт сид с этими же числами.
class UpdateTroopTypeCosts < ActiveRecord::Migration[7.0]
  NEW_COSTS = {
    'Пехота' => [{ 'identificator' => 'meat', 'count' => 50 }],
    'Тяжелая пехота' => [
      { 'identificator' => 'metal', 'count' => 20 },
      { 'identificator' => 'meat', 'count' => 70 }
    ],
    'Кавалерия' => [
      { 'identificator' => 'weapon', 'count' => 5 },
      { 'identificator' => 'horses', 'count' => 30 }
    ],
    'Пушка' => [{ 'identificator' => 'tools', 'count' => 30 }]
  }.freeze

  OLD_COSTS = {
    'Пехота' => [
      { 'identificator' => 'gold', 'count' => 500 },
      { 'identificator' => 'meat', 'count' => 50 }
    ],
    'Тяжелая пехота' => [
      { 'identificator' => 'gold', 'count' => 1000 },
      { 'identificator' => 'meat', 'count' => 70 },
      { 'identificator' => 'metal', 'count' => 20 }
    ],
    'Кавалерия' => [
      { 'identificator' => 'gold', 'count' => 3000 },
      { 'identificator' => 'meat', 'count' => 0 },
      { 'identificator' => 'metal', 'count' => 0 },
      { 'identificator' => 'food', 'count' => 20 },
      { 'identificator' => 'horses', 'count' => 30 },
      { 'identificator' => 'weapon', 'count' => 5 }
    ],
    'Пушка' => [
      { 'identificator' => 'gold', 'count' => 4000 },
      { 'identificator' => 'meat', 'count' => 0 },
      { 'identificator' => 'metal', 'count' => 0 },
      { 'identificator' => 'food', 'count' => 0 },
      { 'identificator' => 'horses', 'count' => 0 },
      { 'identificator' => 'weapon', 'count' => 0 },
      { 'identificator' => 'armor', 'count' => 5 },
      { 'identificator' => 'tools', 'count' => 30 }
    ]
  }.freeze

  def up
    apply_costs(NEW_COSTS)
  end

  def down
    apply_costs(OLD_COSTS)
  end

  private

  # params — колонка типа json (не jsonb), поэтому key-set собираем через jsonb
  # с приведением типа обратно; остальные ключи params сохраняются.
  def apply_costs(costs)
    costs.each do |name, buy_cost|
      say "troop_types «#{name}»: #{buy_cost.map { |item| "#{item['count']} #{item['identificator']}" }.join(' + ')}"
      execute(<<~SQL)
        UPDATE troop_types
           SET params = (COALESCE(params, '{}'::json)::jsonb
                         || jsonb_build_object('buy_cost', #{connection.quote(buy_cost.to_json)}::jsonb))::json
         WHERE name = #{connection.quote(name)}
      SQL
    end
  end
end
