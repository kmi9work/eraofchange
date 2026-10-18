# Показатель «возможно ли производство на добывающих предприятиях» для пары
# «государство × гильдия» (п. 4).
#
# Умолчание: добыча открыта гильдии в стране, к которой гильдия привязана, и
# закрыта в остальных. Строка таблицы — явное переопределение, поэтому и
# «закрыть у себя», и «открыть в чужой стране» выражаются одной записью.
module ManyTeams
  class GuildExtractionPermission < ApplicationRecord
    self.table_name = "many_teams_guild_extraction_permissions"

    belongs_to :guild
    belongs_to :country

    validates :guild_id, uniqueness: { scope: :country_id }

    class << self
      # Разрешена ли гильдии добыча на территории государства.
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

      # Матрица для экрана мастеров: все государства × гильдии государства.
      def matrix_for(country)
        guilds = ::Guild.where(country_id: country&.id).order(:name).to_a
        countries = ::Country.order(:id).to_a
        rows = where(guild_id: guilds.map(&:id)).index_by { |row| [row.guild_id, row.country_id] }

        guilds.map do |guild|
          {
            guild_id: guild.id,
            guild_name: guild.name,
            permissions: countries.map do |item|
              row = rows[[guild.id, item.id]]
              {
                country_id: item.id,
                country_name: item.name,
                country_short_name: item.short_name,
                allowed: row ? row.allowed? : default_allowed?(guild, item),
                overridden: !row.nil?,
                own: guild.country_id.to_i == item.id
              }
            end
          }
        end
      end
    end
  end
end
