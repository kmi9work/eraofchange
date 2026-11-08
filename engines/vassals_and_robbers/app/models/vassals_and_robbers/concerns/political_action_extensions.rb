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
      # Армия передана соседу («Передача армии»). Эффект нужен клиенту мастеров,
      # чтобы пометить армию и предупредить о запрете двигать её: сама передача
      # живёт в params армии (`additional`), но эффект переживает год и знает,
      # какой именно армии он касается.
      ARMY_LEASED = "army_leased"
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
        target = Country.current&.council_players(Job::GRAND_PRINCE)&.first
        return { error: "Великий князь не найден" } unless target

        country = Country.find_by_id(params['country_id'])
        return { error: "Страна не найдена" } unless country

        country.change_relations(2, self, "Личный визит")
        # Цель — сам держатель должности (id + имя): клиенту мастеров нужно
        # понять, чьи армии нельзя двигать, не сверяя только имя.
        GameParameter.register_lingering_effects("make_a_trip", effects, GameParameter.current_year, target)
        { success: true, message: "Отношения с #{country.name} улучшены на 2" }
      end

# Отношения с выбранным соседом не падают ниже "Нейтральных". 
# Если отношения были ниже «Нейтральных» - они повышаются до 
# «Нейтральных». Великий князь не может создавать или улучшать 
# вою армию, пока она в распоряжении соседа.
      
      def transfere_army #Передача армии
        target = Country.current&.council_players(Job::GRAND_PRINCE)&.first
        return {error: "Великий князь не найден"} unless target
      
        # Проверяем, что армия принадлежит Великому князю
        army = target.armies.find_by_id(params["army_id"])
        return {error: "Армия не найдена или не принадлежит Великому князю"} unless army
        
        # Проверяем, не передана ли уже армия
        army_additional = (army.params || {}).dig("additional") || {}
        if army_additional["active"] == true
          leased_to = army_additional["leased_to"] || "другой стране"
          return {error: "Эта армия уже передана стране: #{leased_to}"}
        end
        
        # Проверяем силу армии
        army_power = army.troops.sum{|t| t.power}
        return {error: "Эту армию нельзя передать, так как ее сила меньше 5 (сейчас: #{army_power})"} if army_power < 5
        
        neighbour = Country.find_by_id(params["country_id"])
        return {error: "Страна не найдена"} unless neighbour
        return {error: "Нельзя передать армию своему же государству"} if neighbour.id == army.country_id
        
        # Передаем армию
        army.lease_to(neighbour)

        # Отношения с соседом не падают ниже нейтральных, пока армия у него.
        # Эффект отношения регистрируется на ГОСУДАРСТВО (проверка живёт в
        # Country#change_relations), а признак «армия передана» — на САМУ армию:
        # клиент мастеров по нему красит щит и предупреждает о запрете движения.
        relations_before = neighbour.relations(Country.current)
        effects = []
        if relations_before < 0
          neighbour.change_relations(relations_before.abs, self, "Передача армии")
          effects << NON_NEGATIVE_RELATIONS
        end

        # Эффект держится, пока армия не вернётся (`Army#unlease` снимает записи),
        # но не дольше конца игры: срок задаётся годами, а не «навсегда».
        last_year = [GameParameter.get_years_count.to_i, GameParameter.current_year].max
        years = (GameParameter.current_year..last_year).to_a
        army_target = {
          "type" => "army",
          "id" => army.id,
          "name" => army.name,
          "leased_to" => neighbour.name
        }
        GameParameter.register_lingering_effects("transfere_army", [ARMY_LEASED], years, army_target)
        GameParameter.register_lingering_effects("transfere_army", effects, years, neighbour) if effects.any?
        
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
        return { error: "Гильдия не найдена" } unless target

        target_info = build_guild_target_payload(target)
        GameParameter.register_lingering_effects("invest", effects, GameParameter.current_year + 1, target_info)
      end

        #Передача государевых подвод
        #Армии страны в текущем ходу не могут перемещаться
      def lease_cattle
        effects = [ALL_ARMIES_BLOCKED]
        # Цель — государство, чьи армии задействованы: подводы государевы, чужой
        # мастер их не «тратит». Без цели эффект считался бы всеобщим.
        country = Country.current
        GameParameter.register_lingering_effects("lease_cattle", effects, GameParameter.current_year, country)
        {success: true, message: "Армии государства «#{country&.name}» в этом году не могут перемещаться"}
      end

        #Покровительство иноверцам
      def patronage_of_infidel_vassals #Покровительство иноверцам
        it = Technology.find_by_id(params['technology_id'])
        it&.open_it(Country.current)
        regions = Country.current&.regions || Region.none
        regions.each {|r| PublicOrderItem.add(-1, "Покровительство иноверцам", r, self)}
      end

        #Внедрение инноваций
        #Производительность перерабатывающих предприятий выбранной гильдии увеличивается на 100% в следующем ходу
      def boost_innovation
        effects = [HIGHER_PRODUCTION_YIELD]
        target = Guild.find_by_id(params["guild_id"])
        return { error: "Гильдия не найдена" } unless target

        target_info = build_guild_target_payload(target)
        GameParameter.register_lingering_effects("boost_innovation", effects, GameParameter.current_year + 1, target_info)
      end

      def send_embassy_vassals #Отправить посольство
        country = Country.find_by_id(params['country_id'])
        country.change_relations(1, self)
      end

        #нужны ли тут проверки? Или проверки лучше на фронте?
      def make_alliance
        al_type = AllianceType.find_by(name: params['alliance_type'])
        Alliance.add(country_id: Country.current&.id, 
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
        regions = Country.current&.regions || Region.none
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
        target = Country.current&.council_players(Job::VOEVODA)&.first
        return {error: "Воевода не найден"} unless target

        # Армия, которая охраняет караван: выбирает мастер в диалоге. Это должна
        # быть армия Воеводы — чужую армию он «передать» не может.
        army_id = params["army_id"].presence
        army = nil
        if army_id
          army = target.armies.find_by_id(army_id)
          return {error: "Армия не найдена или не принадлежит Воеводе"} unless army
        end
        
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
        
        # Регистрируем эффект НА ТЕКУЩИЙ ГОД: на выбранную армию, а если армию не
        # выбрали (старый клиент) — на самого Воеводу, как было раньше.
        effect_target =
          if army
            { "type" => "army", "id" => army.id, "name" => army.name }
          else
            target
          end
        GameParameter.register_lingering_effects("protect_caravan", effects, GameParameter.current_year, effect_target)
        
        army_note = army ? "Армия '#{army.name}' охраняет караван." : "Воевода не сможет командовать армией."
        return {success: true, message: "Караван гильдии '#{guild.name}' защищен. #{army_note}"}
      end

        #Контрразведка
      def spy_away_mutiny
        #на фронте будет выбор: убираем армию или повышаем. Если повышаем, то тогда изменения происходят на сервере
        region = Region.find_by_id(params["region_id"])
        if region.show_overall_po(Country.current) < 0
         PublicOrderItem.add(5, "Контрразведка", region, self)
        else
          return {msg: "Нельзя поднять общественный порядок"}
        end
      end

      def infiltrate_army

      end
      
      private

      def build_guild_target_payload(guild)
        return nil unless guild

        {
          "type" => "guild",
          "id" => guild.id,
          "name" => guild.name
        }
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
