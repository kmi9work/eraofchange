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
      NON_NEGATIVE_RELATIONS = "non_negative_relations" #Отношения с выбранным соседом не падают ниже "Нейтральных"
      SINGLE_ARMY_COMPLETE_BLOCK = "single_army_complete_block"
      HIGHER_EXTRACTION_YIELD = "higher_extraction_yield"
      HIGHER_PRODUCTION_YIELD = "higher_production_yield"
      ALL_ARMIES_BLOCKED = "all_armies_blocked"
# ["higher_sell_prices","increased_trade_revenue","no_relation_improvement" ]

#надо сделать:
## # В следующем году нельзя улучшить отношения со странами-импортерами

      def support_export        
        effects = [HIGHER_SELL_PRICES, INCREASED_TRADE_REVENUE, NO_RELATIONS_IMPROVEMENT]
        result = GameParameter.register_lingering_effects("support_export", effects, GameParameter.current_year + 1)
        
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
        GameParameter.register_lingering_effects("make_a_trip", effects, GameParameter.current_year, target.name)
      end

# Отношения с выбранным соседом не падают ниже "Нейтральных". 
# Если отношения были ниже «Нейтральных» - они повышаются до 
# «Нейтральных». Великий князь не может создавать или улучшать 
# вою армию, пока она в распоряжении соседа.
      
      def transfere_army #Передача армии
        effects = []
        target = Job.find_by_id(Job::GRAND_PRINCE).players.first
        return {error: "Великий князь не найден"} unless target
      
        # Проверяем, что армия принадлежит Великому князю
        army = target.armies.find_by_id(params["army_id"])
        return {error: "Армия не найдена или не принадлежит Великому князю"} unless army
        
        # Проверяем, не передана ли уже армия
        if army.params.dig("additional", "active") == true
          leased_to = army.params.dig("additional", "leased_to") || "другой стране"
          return {error: "Эта армия уже передана стране: #{leased_to}"}
        end
        
        # Проверяем силу армии
        army_power = army.troops.sum{|t| t.power}
        return {error: "Эту армию нельзя передать, так как ее сила меньше 5 (сейчас: #{army_power})"} if army_power < 5
        
        neighbour = Country.find_by_id(params["country_id"])
        return {error: "Страна не найдена"} unless neighbour
        
        # Передаем армию
        army.lease_to(neighbour)
        
        # Изменяем отношения
        if neighbour.relations < 0
          # Если отношения отрицательные, поднимаем до нейтральных
          num = (neighbour.relations).abs
          neighbour.change_relations(num, self, "Передача армии")
          # Добавляем эффект - отношения не могут быть ниже нейтральных
          effects << NON_NEGATIVE_RELATIONS
        end

        # Регистрируем эффекты на всю игру (годы 1-7)
        whole_game = (1..7).to_a
        GameParameter.register_lingering_effects("transfere_army", effects, whole_game, [neighbour.name])
        
        return {success: true, message: "Армия '#{army.name}' передана стране '#{neighbour.name}'"}
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
        GameParameter.register_lingering_effects("invest", effects, GameParameter.current_year + 1, target.name)
      end

        #Передача государевых подвод
        #Армии страны в текущем ходу не могут перемещаться
      def lease_cattle
        effects = [ALL_ARMIES_BLOCKED]
        GameParameter.register_lingering_effects("lease_cattle", effects, GameParameter.current_year)
      end

        #Покровительство иноверцам
      def patronage_of_infidel_vassals #Покровительство иноверцам
        it = Technology.find_by_id(params['technology_id'])
        it.open_it
        regions = Country.find_by_id(Country::RUS).regions
        regions.each {|r| PublicOrderItem.add(-1, "Покровительство иноверцам", r, self)}
      end

        #Внедрение инноваций
        #Производительность перерабатывающих предприятий выбранной гильдии увеличивается на 100% в следующем ходу
      def boost_innovation
        effects = [HIGHER_PRODUCTION_YIELD]
        target = Guild.find_by_id(params["guild_id"])
        GameParameter.register_lingering_effects("boost_innovation", effects, GameParameter.current_year + 1, target.name)
        end

      def send_embassy_vassals #Отправить посольство
        country = Country.find_by_id(params['country_id'])
        country.change_relations(1, self)
      end

        #нужны ли тут проверки? Или проверки лучше на фронте?
      def make_alliance
        al_type = AllianceType.find_by(name: params['alliance_type'])
        Alliance.add(country_id: Country::RUS, 
                     partner_country_id: params["country_id"], 
                     alliance_type_id: al_type.id)
      end

        #Принести дары (для иностранцев)
      def bring_gifts_to_foreign_countries
        country = Country.foreign_countries.find_by_id(params['country_id'])
        country.change_relations(1, self, "Принести дары")
      end

        #Призыв к единству
      def call_for_unity_vassals 
        country = Country.find_by_id(params['country_id'])
        country.change_relations(1, self, "Призыв к единству")
      end

        #Проповедь
      def sermon_vassals 
          region = Region.find_by_id(params['region_id'])
          PublicOrderItem.add(5, self.political_action_type.name, region, self) if region
      end

        #Принести дары (для Руси)
      def bring_gifts_to_russian_countries
        country = Country.russian_countries.find_by_id(params['country_id'])
        country.change_relations(1, self, "Принести дары")
      end

        #Набрать рекрутов
      def recruiting_vassals        
        regions = Country.find_by_id(Country::RUS).regions
        regions.each {|r| PublicOrderItem.add(-1, "Набрать рекрутов", r, self)}
      end

        #Защита каравана
        #Воевода не может распоряжаться своей армией в текущем году
      def protect_caravan
        effects = [SINGLE_ARMY_COMPLETE_BLOCK]
        
        # Проверяем наличие гильдии
        guild = Guild.find_by_id(params["guild_id"])
        return {error: "Гильдия не найдена"} unless guild
        
        # Проверяем наличие воеводы
        target = Job.find_by_id(Job::VOEVODA)&.players&.first
        return {error: "Воевода не найден"} unless target
        
        # Обновляем params гильдии (для исторических данных)
        current_guild_params = guild.params || {}
        protected_years = current_guild_params["caravan_protected"] || []
        protected_years << GameParameter.current_year
        
        current_guild_params["caravan_protected"] = protected_years
        guild.params = current_guild_params
        guild.params_will_change!
        guild.save
        
        # СИНХРОНИЗАЦИЯ: Обновляем protected_guilds_by_year для корректной работы check_robbery
        GameParameter.add_protected_guild_for_year(guild.id, GameParameter.current_year)
        
        # Регистрируем эффект для воеводы НА ТЕКУЩИЙ ГОД
        GameParameter.register_lingering_effects("protect_caravan", effects, GameParameter.current_year, target.name)
        
        return {success: true, message: "Караван гильдии '#{guild.name}' защищен. Воевода не сможет командовать армией в текущем году."}
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
