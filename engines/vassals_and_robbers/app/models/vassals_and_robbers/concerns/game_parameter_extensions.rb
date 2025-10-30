# EXAMPLE: Это шаблонный файл для создания своего Engine
module VassalsAndRobbers
  module Concerns
    module GameParameterExtensions
      extend ActiveSupport::Concern

      included do
        # В игре Vassals and Robbers циклы запускаются автоматически
        self.auto_start_next_cycle = true
      end

      class_methods do
        # Методы класса
      end
    end
  end
end

