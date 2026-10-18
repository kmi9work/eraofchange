# Пункт 3: цены в many_teams не зависят от отношений — берётся уровень 0.
#
# Модуль ставится в singleton_class Resource (prepend): перекрывает и
# Resource.show_prices (витрина рынка), и Resource.calculate_cost (расчёт
# каравана), потому что оба читают params цены по ключу уровня отношений.
module ManyTeams
  module Concerns
    module ResourceClassExtensions
      ZERO_RELATIONS = "0".freeze

      def show_prices
        return super unless ManyTeams.active?

        off_market = []
        to_market = []

        Resource.all.each do |res|
          to_prices = { name: res.name, identificator: res.identificator }
          off_prices = { name: res.name, identificator: res.identificator }

          if res.country_id
            country = res.country
            to_prices[:country] = country.as_json(only: %i[id name])
            to_prices[:country_id] = country.id
            to_prices[:embargo] = country.embargo if country&.params
            off_prices[:country] = to_prices[:country]
            off_prices[:country_id] = country.id
            off_prices[:embargo] = to_prices[:embargo]
          else
            to_prices[:country] = nil
            to_prices[:country_id] = nil
            to_prices[:embargo] = 0
            off_prices[:country] = nil
            off_prices[:country_id] = nil
            off_prices[:embargo] = 0
          end

          sell = price_at_zero(res, "buy_price")
          buy = price_at_zero(res, "sale_price")

          if sell
            to_prices[:sell_price] = sell
            to_market.push(to_prices)
          end
          if buy
            off_prices[:buy_price] = buy
            off_market.push(off_prices)
          end
        end

        prices = { off_market: off_market, to_market: to_market }
        if GameParameter.any_lingering_effects?("higher_sell_prices", GameParameter.current_year)
          Resource.increase_prices(prices)
        else
          prices
        end
      end

      def calculate_cost(transaction_type, amount, resource)
        return super unless ManyTeams.active?

        unit_cost = price_at_zero(resource, "#{transaction_type}_price")
        embargo = resource.country&.params&.dig("embargo").to_i
        if unit_cost
          { identificator: resource.identificator, count: amount, cost: unit_cost * amount.to_i, embargo: embargo }
        else
          { identificator: resource.identificator, count: amount, cost: nil, embargo: embargo }
        end
      end

      private

      # Цена по уровню отношений 0. Ключ может быть строкой ("0") — как в сидах —
      # или числом (0); допускаем оба, чтобы не зависеть от формата JSON.
      def price_at_zero(resource, key)
        table = resource.params[key] || resource.params[key.to_sym]
        return nil unless table.respond_to?(:[])

        table[ZERO_RELATIONS] || table[0]
      end
    end
  end
end
