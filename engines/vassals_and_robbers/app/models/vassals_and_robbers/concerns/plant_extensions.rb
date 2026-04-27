# EXAMPLE: Это шаблонный файл для создания своего Engine
module VassalsAndRobbers
  module Concerns
    module PlantExtensions
      extend ActiveSupport::Concern

      included do
        # TODO: Добавьте associations для функционала игры
        # Например:
        # has_many :vassals_tributes, class_name: 'VassalsAndRobbers::VassalTribute'
        
        # TODO: Добавьте callbacks
        # after_create :initialize_game_params
        
        # TODO: Добавьте scopes
        # scope :active_in_game, -> { where(...) }
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

