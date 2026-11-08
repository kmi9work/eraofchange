module VassalsAndRobbers
  module Concerns
    # Правила игры для построек: в «Вассалах и разбойниках» крепость имеет ОДИН
    # уровень («Форт»), поэтому улучшать её некуда. Уровни 2-3 справочника
    # («Крепость», «Кремль») в этой игре не используются — их убирает сид
    # engines/vassals_and_robbers/db/seeds/6_fortresses.rb.
    #
    # Модуль подключается через `prepend`, а не `include`: он перекрывает
    # существующий метод ядра `Building#upgrade!` и вызывает его через `super`.
    module BuildingExtensions
      extend ActiveSupport::Concern

      def upgrade!(zodchiy_bonus = nil)
        if building_level&.building_type_id == BuildingType::DEFENCE
          return {
            building_level: nil,
            msg: "В этой игре у крепости один уровень — улучшать её нельзя."
          }
        end

        super
      end
    end
  end
end
