# Разрешение гильдии в государстве: можно ли ей строить предприятия и работать
# на территории этого государства (п. 0-2). Запрет один — он одновременно
# закрывает строительство и работу уже построенных предприятий, категория
# предприятия роли не играет.
#
# Умолчание: открыто в стране, к которой привязана гильдия, и закрыто в
# остальных. Строка таблицы — явное переопределение, поэтому и «закрыть у себя»,
# и «открыть в чужой стране» выражаются одной записью. Ставят запрет Казначей
# (политдействие) и мастера на «Экономика → Дашборд».
module ManyTeams
  class GuildCountryPermission < ApplicationRecord
    self.table_name = "many_teams_guild_country_permissions"

    belongs_to :guild
    belongs_to :country

    validates :guild_id, uniqueness: { scope: :country_id }

    class << self
      # Разрешены ли гильдии строительство и работа предприятий в государстве.
      def allowed?(guild, country)
        return false if guild.nil? || country.nil?

        row = find_by(guild_id: guild.id, country_id: country.id)
        return row.allowed? if row

        default_allowed?(guild, country)
      end

      # Умолчание: своя страна — открыто, чужая — закрыто.
      def default_allowed?(guild, country)
        guild.country_id.present? && guild.country_id.to_i == country.id.to_i
      end

      # Есть ли явное переопределение (для отображения «изменено вручную»).
      def overridden?(guild, country)
        exists?(guild_id: guild.id, country_id: country.id)
      end

      def set!(guild, country, allowed, comment: nil, year: nil)
        row = find_or_initialize_by(guild_id: guild.id, country_id: country.id)
        row.allowed = !!allowed
        row.comment = comment
        row.year = year || GameParameter.current_year
        row.save!
        row
      end

      # Сброс к умолчанию — удаление переопределения.
      def reset!(guild, country)
        find_by(guild_id: guild.id, country_id: country.id)&.destroy
      end

      # Таблица для экрана мастеров: ВСЕ гильдии игры и разрешение для одной
      # страны — той, на территории которой решают. Переключатель в строке значит
      # «строительство и работа предприятий разрешены на территории этой страны»;
      # чужие территории отсюда не правятся (решение заказчика: одна страна —
      # одна колонка).
      def matrix_for(country)
        guilds = ::Guild.includes(:country).order(:name).to_a
        return [] if country.nil?

        rows = where(country_id: country.id, guild_id: guilds.map(&:id)).index_by(&:guild_id)

        guilds.map do |guild|
          row = rows[guild.id]
          {
            guild_id: guild.id,
            guild_name: guild.name,
            guild_country_id: guild.country_id,
            guild_country_name: guild.country&.name,
            own: guild.country_id.to_i == country.id.to_i,
            allowed: row ? row.allowed? : default_allowed?(guild, country),
            overridden: !row.nil?
          }
        end
      end
    end
  end
end
