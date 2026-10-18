# Государства игроков, подтверждённые на странице «Дашборд» (п. 7).
# Только на их территории гильдии могут строить предприятия.
#
# Если набор пуст (мастера ещё не подтвердили выбор), ограничение не действует:
# играбельно любое государство — иначе на чистой базе нельзя было бы строить
# ничего. Это же правило действует, когда движок выключен.
module ManyTeams
  class PlayerCountry < ApplicationRecord
    self.table_name = "many_teams_player_countries"

    belongs_to :country

    class << self
      def ids
        order(:country_id).pluck(:country_id)
      end

      def confirmed?(country)
        return false if country.nil?

        exists?(country_id: country.id)
      end

      # Можно ли строить на территории государства.
      def buildable?(country)
        return false if country.nil?
        return true if ids.empty?

        ids.include?(country.id)
      end

      # Полная замена набора (кнопка «Подтвердить выбор»).
      def replace!(country_ids, year: nil)
        ids = Array(country_ids).map(&:to_i).uniq.select { |id| ::Country.exists?(id: id) }
        transaction do
          where.not(country_id: ids).destroy_all
          ids.each do |country_id|
            find_or_create_by!(country_id: country_id) do |row|
              row.year = year || GameParameter.current_year
            end
          end
        end
        ids
      end
    end
  end
end
