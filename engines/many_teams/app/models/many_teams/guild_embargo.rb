# Эмбарго государства на гильдию (п. 9).
#
# Эмбарго накладывается страной на одну гильдию; кнопка «на все гильдии
# выбранной страны» создаёт по строке на каждую гильдию этой страны. Эмбарго
# на уровне страны (Country#params["embargo"]) остаётся как было — это разные
# сущности, старые экраны продолжают работать.
module ManyTeams
  class GuildEmbargo < ApplicationRecord
    self.table_name = "many_teams_guild_embargoes"

    belongs_to :country # кто наложил
    belongs_to :guild   # на кого наложено

    validates :guild_id, uniqueness: { scope: :country_id }

    class << self
      def embargoed?(country, guild)
        return false if country.nil? || guild.nil?

        exists?(country_id: country.id, guild_id: guild.id)
      end

      def impose!(country, guild, comment: nil, year: nil)
        row = find_or_initialize_by(country_id: country.id, guild_id: guild.id)
        row.comment = comment
        row.year = year || GameParameter.current_year
        row.save!
        row
      end

      def lift!(country, guild)
        find_by(country_id: country.id, guild_id: guild.id)&.destroy
      end

      # Все эмбарго, наложенные на гильдию (любыми странами).
      def lift_all_for_guild!(guild)
        where(guild_id: guild.id).destroy_all
      end

      # Эмбарго одной страны на все гильдии выбранной страны.
      def impose_country_on_all!(imposer, target_country, comment: nil, year: nil)
        guilds = ::Guild.where(country_id: target_country&.id).to_a
        guilds.map { |guild| impose!(imposer, guild, comment: comment, year: year) }
      end

      def for_guild(guild)
        where(guild_id: guild.id)
      end

      def by_imposer(country)
        where(country_id: country.id)
      end
    end
  end
end
