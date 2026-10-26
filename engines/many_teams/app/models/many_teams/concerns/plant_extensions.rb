# Правила many_teams по предприятиям гильдий (п. 0-2 заказчика).
#
# Запрет ОДИН и закрывает одновременно строительство предприятия и работу уже
# построенного; категория предприятия (добывающее/перерабатывающее) роли не
# играет. Хранится парой «гильдия × государство» в
# ManyTeams::GuildCountryPermission: по умолчанию открыто в стране гильдии и
# закрыто в остальных, Казначей и мастера («Экономика → Дашборд») правят это
# переопределением.
#
# Сервер предприятие НЕ блокирует: запрет — предупреждение для мастера
# (п. 4: «Построить всё равно можно»). Поэтому валидации на Plant нет, есть
# только предикат для API.
module ManyTeams
  module Concerns
    module PlantExtensions
      def many_teams_extractive?
        !!plant_level&.plant_type&.plant_category&.is_extractive
      end

      def many_teams_build_country
        plant_place&.region&.country
      end

      # Ярлык для API: запрещены ли в государстве расположения строительство и
      # работа этого предприятия (одно и то же разрешение гильдии).
      def many_teams_work_forbidden?
        return false unless ManyTeams.active?

        guild = economic_subject
        return false unless guild.is_a?(::Guild)

        country = many_teams_build_country
        return false if country.nil?

        !ManyTeams::GuildCountryPermission.allowed?(guild, country)
      end
    end
  end
end
