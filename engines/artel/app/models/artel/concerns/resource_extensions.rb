# frozen_string_literal: true

# В игре Artel ресурсы не привязаны к стране (country_id: nil), используется только уровень отношений 0.
# Расширяет Resource: цены по ключу 0, показ цен и расчёт стоимости без страны.
module Artel
  module Concerns
    module ResourceExtensions
      extend ActiveSupport::Concern

      included do
        class << self
          alias_method :artel_original_country_filter, :country_filter
          alias_method :artel_original_send_caravan, :send_caravan
          alias_method :artel_original_calculate_cost, :calculate_cost
          alias_method :artel_original_show_prices, :show_prices
        end
      end

      class_methods do
        def country_filter(country_id, resources)
          if country_id.nil? && ENV["ACTIVE_GAME"] == "artel"
            resources.select do |res|
              Resource.where(country_id: nil, identificator: res[:identificator]).exists?
            end
          else
            artel_original_country_filter(country_id, resources)
          end
        end

        def send_caravan(country_id, res_pl_sells = [], res_pl_buys = [])
          if ENV["ACTIVE_GAME"] == "artel"
            raise ArgumentError, "res_pl_sells must be an array" unless res_pl_sells.is_a?(Array)
            raise ArgumentError, "res_pl_buys must be an array" unless res_pl_buys.is_a?(Array)
            country_id = nil if country_id.blank?
          else
            raise ArgumentError, "country_id is required" if country_id.blank?
          end
          artel_original_send_caravan(country_id, res_pl_sells, res_pl_buys)
        end

        def calculate_cost(transaction_type, amount, resource)
          if resource.country_id.nil? && ENV["ACTIVE_GAME"] == "artel"
            unit_cost = resource.params["#{transaction_type}_price"]&.[](0)
            if unit_cost
              { identificator: resource.identificator, count: amount, cost: unit_cost * amount.to_i, embargo: false }
            else
              { identificator: resource.identificator, count: amount, cost: nil, embargo: false }
            end
          else
            artel_original_calculate_cost(transaction_type, amount, resource)
          end
        end

        def show_prices
          if ENV["ACTIVE_GAME"] != "artel"
            return artel_original_show_prices
          end

          # Контекст текущего государства: если у него есть свои ресурсы — берём их,
          # иначе остаёмся на общих ресурсах Артели (country_id: nil), как было
          current_country = Country.current
          resources = current_country ? Resource.where(country_id: current_country.id) : Resource.none
          resources = Resource.where(country_id: nil) if resources.empty?
          off_market = []
          to_market = []

          resources.each do |res|
            # Уровень цены — по паре отношений страны ресурса с текущим государством
            rel_key = res.country_id.nil? ? 0 : res.country.relations(current_country).to_s
            not_for_sale = res.params["sale_price"]&.[](rel_key).nil?

            country_payload = res.country_id ? { id: res.country_id, name: res.country&.name } : nil

            to_prices = { name: res.name, identificator: res.identificator, sell_price: res.params["buy_price"]&.[](rel_key), embargo: false, country: country_payload, country_id: res.country_id }
            off_prices = { name: res.name, identificator: res.identificator, buy_price: res.params["sale_price"]&.[](rel_key), embargo: false, country: country_payload, country_id: res.country_id }

            to_market.push(to_prices)
            off_market.push(off_prices) unless not_for_sale
          end

          off_and_to_market_prices = { off_market: off_market, to_market: to_market }
          return off_and_to_market_prices unless GameParameter.respond_to?(:any_lingering_effects?) && GameParameter.any_lingering_effects?("higher_sell_prices", GameParameter.current_year)

          Resource.increase_prices(off_and_to_market_prices)
        end
      end
    end
  end
end
