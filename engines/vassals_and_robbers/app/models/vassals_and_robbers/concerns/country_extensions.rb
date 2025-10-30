module VassalsAndRobbers
  module Concerns
    module CountryExtensions
      extend ActiveSupport::Concern

      included do
        # В игре Vassals and Robbers бонус от технологии "Москва — Третий Рим" = 1
        self.moscow_third_rome_bonus = 1

        # TODO: Добавьте associations для функционала игры
        # Например:
        # has_many :game_vassals, class_name: 'VassalsAndRobbers::Vassal'
        
        # TODO: Добавьте callbacks
        # after_update :update_game_state
        
        # TODO: Добавьте scopes
        # scope :with_vassals, -> { joins(:game_vassals) }
      end

      # Instance methods
      # TODO: Добавьте методы экземпляра
      # def custom_method
      #   # your code
      # end

      # Class methods
      class_methods do
        # TODO: Добавьте методы класса
        # def custom_class_method
        #   # your code
        # end
      end
    end
  end
end

