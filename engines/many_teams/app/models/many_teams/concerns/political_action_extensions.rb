# Новые политдействия движка many_teams (п. 5, 10, 11).
#
# PoliticalAction#execute вызывает метод по колонке `action` каталога типов,
# если модель на него отвечает. Методы ниже добавляются в модель из движка —
# ядро не правится.
module ManyTeams
  module Concerns
    module PoliticalActionExtensions
      # ---- п. 5: Казначей разрешает/запрещает добычу гильдии ----
      def set_guild_extraction
        guild = ::Guild.find_by(id: action_param(:guild_id))
        raise ManyTeams::Error, "Гильдия не найдена" if guild.nil?

        country = ::Country.find_by(id: action_param(:country_id)) || Country.current
        raise ManyTeams::Error, "Государство не найдено" if country.nil?

        allowed = ActiveModel::Type::Boolean.new.cast(action_param(:allowed))
        ManyTeams::GuildExtractionPermission.set!(
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
      def lift_guild_embargoes
        technology = ::Technology.find_by(id: 8) # Technology::OVERSEAS_TRADE
        unless technology && technology.is_open(Country.current) == 1
          raise ManyTeams::Error, "Действие доступно только при открытой технологии «#{technology&.name || 'Заморская торговля'}»"
        end

        guild = ::Guild.find_by(id: action_param(:guild_id))
        raise ManyTeams::Error, "Гильдия не найдена" if guild.nil?

        lifted = ManyTeams::GuildEmbargo.where(guild_id: guild.id).pluck(:country_id)
        ManyTeams::GuildEmbargo.lift_all_for_guild!(guild)

        self.params = (params || {}).merge(
          "guild_id" => guild.id,
          "guild_name" => guild.name,
          "lifted_country_ids" => lifted
        )
        save!
        { guild_id: guild.id, lifted_country_ids: lifted }
      end

      # ---- п. 11: Тайный советник — разведка ----
      def conduct_intelligence
        report = ManyTeams::IntelligenceService.new(self).report
        self.params = (params || {}).merge("report" => report)
        save!
        report
      end

      # ---- п. 11: подорвать стабильность в регионе (-3) ----
      def undermine_stability
        region = ::Region.find_by(id: action_param(:region_id))
        raise ManyTeams::Error, "Регион не найден" if region.nil?

        ::PublicOrderItem.add(-3, political_action_type&.name, region, self)
        self.params = (params || {}).merge(
          "region_id" => region.id,
          "region_name" => region.name,
          "public_order_delta" => -3
        )
        save!
        { region_id: region.id, public_order_delta: -3 }
      end

      # ---- п. 11: подорвать отношения двух стран (-1) ----
      def undermine_relations
        pair = ManyTeams::IntelligenceService.new(self).relation_pair
        first, second = pair

        first.change_relations(-1, self, partner: second)
        self.params = (params || {}).merge(
          "country_a_id" => first.id,
          "country_b_id" => second.id,
          "relations_delta" => -1
        )
        save!
        { country_a_id: first.id, country_b_id: second.id, relations_delta: -1 }
      end

      private

      def action_param(key)
        (params || {})[key.to_s] || (params || {})[key.to_sym]
      end
    end
  end
end
