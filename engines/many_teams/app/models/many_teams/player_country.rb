# Государства игроков, подтверждённые на странице «Дашборд» (п. 7).
#
# Набор отвечает на вопрос «за какие государства играют команды»: по нему
# считаются соперники в разведке и определяются государства игроков в других
# механиках режима. К строительству предприятий он больше НЕ относится —
# единственный запрет там задаёт ManyTeams::GuildCountryPermission (п. 0-2).
#
# Если набор пуст (мастера ещё не подтвердили выбор), разведка считает, что
# соперников нет: играбельно любое государство.
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
