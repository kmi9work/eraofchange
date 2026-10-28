# Новые политдействия движка many_teams (п. 5, 10, 11).
#
# PoliticalAction#execute вызывает метод по колонке `action` каталога типов,
# если модель на него отвечает. Методы ниже добавляются в модель из движка —
# ядро не правится.
module ManyTeams
  module Concerns
    module PoliticalActionExtensions
      # ---- п. 2: Казначей разрешает/запрещает гильдии строительство и работу ----
      def set_guild_permission
        guild = ::Guild.find_by(id: action_param(:guild_id))
        raise ManyTeams::Error, "Гильдия не найдена" if guild.nil?

        country = ::Country.find_by(id: action_param(:country_id)) || Country.current
        raise ManyTeams::Error, "Государство не найдено" if country.nil?

        allowed = ActiveModel::Type::Boolean.new.cast(action_param(:allowed))
        ManyTeams::GuildCountryPermission.set!(
          guild, country, allowed,
          comment: political_action_type&.name,
          year: year
        )

        self.params = (params || {}).merge(
          "guild_id" => guild.id,
          "guild_name" => guild.name,
          "country_id" => country.id,
          "country_name" => country.name,
          "allowed" => !!allowed
        )
        save!
        { guild_id: guild.id, country_id: country.id, allowed: !!allowed }
      end

      # ---- п. 10: Великий князь снимает все эмбарго с гильдии ----
      # Технология «Заморская торговля» — условие правил, но не блокировка
      # (решение заказчика): экран предупреждает, действие выполняется всегда.
      # Факт закрытой технологии сохраняем в params — по записи политдействия
      # видно, что правило было нарушено.
      def lift_guild_embargoes
        overseas_trade_open = ManyTeams::GuildEmbargo.overseas_trade_open?(Country.current)

        guild = ::Guild.find_by(id: action_param(:guild_id))
        raise ManyTeams::Error, "Гильдия не найдена" if guild.nil?

        lifted = ManyTeams::GuildEmbargo.where(guild_id: guild.id).pluck(:country_id)
        ManyTeams::GuildEmbargo.lift_all_for_guild!(guild)

        self.params = (params || {}).merge(
          "guild_id" => guild.id,
          "guild_name" => guild.name,
          "lifted_country_ids" => lifted,
          "overseas_trade_open" => overseas_trade_open
        )
        save!
        { guild_id: guild.id, lifted_country_ids: lifted, overseas_trade_open: overseas_trade_open }
      end

      # ---- п. 11: Тайный советник — разведка ----
      # Влияние зависит от пункта разведки (1/1/2/2) и начисляется при успехе.
      def conduct_intelligence
        report = ManyTeams::IntelligenceService.new(self).report
        influence = success.to_i == 1 ? ManyTeams::IntelligenceService.influence_for(report["intel_type"]) : 0

        self.params = (params || {}).merge("report" => report, "influence_delta" => influence)
        save!
        modify_influence(influence) unless influence.zero?
        report
      end

      # ---- п. 11: подорвать стабильность в регионе (-3) ----
      def undermine_stability
        region = ::Region.find_by(id: action_param(:region_id))
        raise ManyTeams::Error, "Регион не найден" if region.nil?

        influence = success.to_i == 1 ? ManyTeams::IntelligenceService::INFLUENCE_UNDERMINE : 0

        ::PublicOrderItem.add(-3, political_action_type&.name, region, self)
        self.params = (params || {}).merge(
          "region_id" => region.id,
          "region_name" => region.name,
          "public_order_delta" => -3,
          "influence_delta" => influence
        )
        save!
        modify_influence(influence) unless influence.zero?
        { region_id: region.id, public_order_delta: -3, influence_delta: influence }
      end

      # ---- п. 11: подорвать отношения двух стран (-1) ----
      def undermine_relations
        pair = ManyTeams::IntelligenceService.new(self).relation_pair
        first, second = pair

        influence = success.to_i == 1 ? ManyTeams::IntelligenceService::INFLUENCE_UNDERMINE : 0

        first.change_relations(-1, self, partner: second)
        self.params = (params || {}).merge(
          "country_a_id" => first.id,
          "country_b_id" => second.id,
          "relations_delta" => -1,
          "influence_delta" => influence
        )
        save!
        modify_influence(influence) unless influence.zero?
        { country_a_id: first.id, country_b_id: second.id, relations_delta: -1, influence_delta: influence }
      end

      private

      def action_param(key)
        (params || {})[key.to_s] || (params || {})[key.to_sym]
      end
    end
  end
end
