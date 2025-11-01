module VassalsAndRobbers
  module Concerns
    module PoliticalActionExtensions
      extend ActiveSupport::Concern

      included do
      end

      class_methods do

        def support_export
          g_p =  GameParameter.find_by(identificator: "lingering_effects")
          g_p.params << {year: GameParameter.current_year + 1, effect: "support_export"}
          g_p.save
        end


# Отношения с выбранной страной улучшаются на 2 пункта. В этом цикле Великий князь не может командовать армией.

        def make_a_trip(country_id)
          #### CHANGE_RELATIONS
          g_p = GameParameter.find_by(identificator: "lingering_effects")
          g_p.params << {year: GameParameter.current_year, effect: "make_a_trip"}
          g_p.save
        end

        def transfere_army(whom)


        end

        def build_fort(settlement_id)
           settle = Settlement.find_by_id(settlement_id)
           b_t = BuildingType.all.where(name: "Кремль")[0].id
           settle.build(b_t)
           settle.save
        end






      end
    end
  end
end

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
