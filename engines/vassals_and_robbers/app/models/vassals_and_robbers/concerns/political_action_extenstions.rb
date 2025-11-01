module VassalsAndRobbers
  module Concerns
    module PoliticalActionExtensions
      extend ActiveSupport::Concern

      included do
      end


      HIGHER_SELL_PRICES = "higher_sell_prices" # Цена продажи товаров  на рынке вырастает на 20%.
      INCREASED_TRADE_REVENUE = "increased_trade_revenue" # Казна по итогам года получает 10% от стоимости всех проданных за рубеж товаров. 
      NO_RELATIONS_IMPROVEMENT = "no_relation_improvement" # В следующем году нельзя улучшить отношения со странами-импортерами
      NO_ARMY_MOVEMENT = "no_army_movement"
      NON_NEGATIVE_RELATIONS = "non_negative_relations"
      SINGLE_ARMY_COMPLETE_BLOCK = "single_army_complete_block"
      HIGHER_EXTRACTION_YIELD = "higher_extraction_yield"
      HIGHER_PRODUCTION_YIELD = "higher_production_yield"
      ALL_ARMIES_BLOCKED = "all_armies_blocked"
# ["higher_sell_prices","increased_trade_revenue","no_relation_improvement" ]

#надо сделать:
## # В следующем году нельзя улучшить отношения со странами-импортерами

      def support_export
        Rails.logger.info "[PoliticalAction] support_export called"
        effects = [HIGHER_SELL_PRICES, INCREASED_TRADE_REVENUE, NO_RELATIONS_IMPROVEMENT]
        Rails.logger.info "[PoliticalAction] Effects to register: #{effects.inspect}"
        Rails.logger.info "[PoliticalAction] Year: #{GameParameter.current_year + 1}"
        
        result = GameParameter.register_lingering_effects("support_export", effects, GameParameter.current_year + 1)
        Rails.logger.info "[PoliticalAction] register_lingering_effects result: #{result.inspect}"
        
        # Проверяем, что эффекты действительно сохранились
        g_p = GameParameter.find_by(identificator: GameParameter::LINGERING_EFFECTS)
        Rails.logger.info "[PoliticalAction] Current lingering_effects params: #{g_p&.params&.inspect}"
        
        return {success: true, message: "Эффекты экспорта зарегистрированы"}
      end

    #year - год, когда он действует. 
    # name_of_action - название полит.действия
    # effect - сам эффект
    # target  - на кого он действует

# Отношения с выбранной страной улучшаются на 2 пункта. В этом цикле Великий князь не может командовать армией.
# функционал того, что нельзя двигать есть. Но нужно отоборажение

        def make_a_trip
          effects = [NO_ARMY_MOVEMENT]
          target = Job.find_by_id(Job::GRAND_PRINCE).players.first
          country = Country.find_by_id(params['country_id'])
          country.change_relations(2, self, "Личный визит")
          effects = []
          GameParameter.register_lingering_effects("make_a_trip", effects, GameParameter.current_year, target)
        end

# Отношения с выбранным соседом не падают ниже "Нейтральных". 
# Если отношения были ниже «Нейтральных» - они повышаются до 
# «Нейтральных». Великий князь не может создавать или улучшать 
# вою армию, пока она в распоряжении соседа.
        
        def transfere_army #Передача армии
          effects = []
          army = Army.find_by_id(params["army_id"])
          return "Эту армию нельзя передать" if army.troops.sum{|t| t.power} < 5  
          target = Job.find_by_id(Job::GRAND_PRINCE).players.first
          neighbour = Country.find_by_id(params["country_id"])
          army.lease_to(neighbour)
          if neighbour.relations > 0
            num = (neighbour.relations).abs
            neighbour.change_relations(num, self, "Принести дары")
          else
            effects << NON_NEGATIVE_RELATIONS
          end
          whole_game = (1..7).to_a
          GameParameter.register_lingering_effects("transfere_army", effects, whole_game, target)

        end

        def build_fort #Возвести форт
           settle = Settlement.find_by_id(params['settlement_id'])
           b_t = BuildingType.all.where(name: "Кремль")[0].id
           settle.build(b_t)
           settle.save
        end
#надо сделать:
#проверку для предприятий
        def invest #Инвестиции
          effects = [HIGHER_EXTRACTION_YIELD]
          target = Guild.find_by_id(params["guild_id"])
          GameParameter.register_lingering_effects("invest", effects, GameParameter.current_year + 1, target)
        end

        #Передача государевых подвод
        #Армии страны в текущем ходу не могут перемещаться
        def lease_cattle
          effects = [ALL_ARMIES_BLOCKED]
          GameParameter.register_lingering_effects("lease_cattle", effects, GameParameter.current_year + 1)
        end


        #Покровительство иноверцам
        def patronage_of_infidel #Покровительство иноверцам
          it = Technology.find_by_id(params['technology_id'])
          it.open_it
          regions = Country.find_by_id(Country::RUS).regions
          regions.each {|r| PublicOrderItem.add(-1, "Покровительство иноверцам", r, self)}
        end

        #Внедрение инноваций
        #Производительность перерабатывающих предприятий выбранной гильдии увеличивается на 20% в следующем ходу
        def boost_innovation
          effects = [HIGHER_PRODUCTION_YIELD]
          target = Guild.find_by_id(params["guild_id"])
          GameParameter.register_lingering_effects("boost_innovation", effects, GameParameter.current_year + 1, target)
        end

        def send_embassy #Отправить посольство
          countries = Country.where(id: params['country_ids'])
          if countries.present?
           countries.each {|c| c.change_relations(1, self)}
          end
        end


        #нужны ли тут проверки? Или проверки лучше на фронте?
        def make_alliance
          al_type = AllianceType.find_by(name: params['alliance_type'])
          Alliance.add(country_id: params["country_id"], 
                       partner_country_id: params["partner_country_id"], 
                       alliance_type_id: al_type.id)

        end
        #Принести дары (для иностранцев)
        def bring_gifts_to_foreign_countries
          country = Country.foreing_countries.find_by_id(params['country_id'])
          country.change_relations(1, self, "Принести дары")
        end

        #Призыв к единству
        def call_for_unity 
          country = Country.find_by_id(params['country_id'])
          country.change_relations(1, self, "Призыв к единству")
        end

        #Проповедь
        def sermon 
            region = Region.find_by_id(params['region_id'])
            PublicOrderItem.add(5, self.political_action_type.name, region, self) if region
        end

        #Принести дары (для Руси)
        def bring_gifts_to_russian_countries
          country = Country.russian_countries.find_by_id(params['country_id'])
          country.change_relations(1, self, "Принести дары")
        end

        #Набрать рекрутов
        def recruiting 
          regions = Country.find_by_id(Country::RUS).regions
          regions.each {|r| PublicOrderItem.add(-1, "Набрать рекрутов", r, self)}
        end

        #Защита каравана
        #Воевода не может распоряжаться своей армией в текущем году
        def protect_caravan
          effects = [SINGLE_ARMY_COMPLETE_BLOCK]
          guild = Guild.find_by_id(params["guild_id"])
          guild.params[:caravan_protected] << GameParameter.current_year
          target = Job.find_by_id(Job::VOEVODA).players.first

          GameParameter.register_lingering_effects("protect_caravan", effects, GameParameter.current_year + 1, target)
        end

        #Контрразведка
        def spy_away_mutiny
        #на фронте будет выбор: убираем армию или повышаем. Если повышаем, то тогда изменения происходят на сервере
        region = Region.find_by_id(params["region_id"])
        if region.show_overall_po < 0
          PublicOrderItem.add(5, "Контрразведка", region, self)
        else
          return {msg: "Нельзя поднять общественный порядок"}
        end
        end

      def infiltrate_army

      end
    end
  end
end




 
  

##надо сделать:

# Тайный советник убирает со стратегической карты одну 
# из армий мятежников 
# по своему выбору или повышает общественный порядок в регионе на 5, если он ниже 0.






# Поддержать экспорт
# Личный визит
# Передача армии

# Инвестиции
# Передача государевых подвод

# Покровительство иноверцам
# Внедрение инноваций

# Отправить посольство
# Заключить союз
# Принести дары

# Призыв к единству
# Проповедь
# Принести дары

# Набрать рекрутов
# Защита каравана

# Контрразведка
# Разведка
