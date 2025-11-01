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
        # Переопределяем метод default_schedule для возврата расписания плагина
        def default_schedule
          [
            { id: 1, identificator: "Регистрация", start: "10:30", finish: "11:00", type: "pause" },
            { id: 2, identificator: "Инструктаж знати", start: "11:00", finish: "11:15", type: "pause" },
            { id: 3, identificator: "Распределение ролей знати", start: "11:15", finish: "11:30", type: "pause" },
            { id: 4, identificator: "Инструктаж купцов", start: "11:00", finish: "11:30", type: "pause" },
            { id: 5, identificator: "Вводное слово Главного мастера", start: "11:30", finish: "11:35", type: "pause" },
            { id: 6, identificator: "1 цикл", start: "11:35", finish: "12:20", type: "play" },
            { id: 7, identificator: "Перерыв", start: "12:20", finish: "12:25", type: "pause" },
            { id: 8, identificator: "2 цикл", start: "12:25", finish: "13:00", type: "play" },
            { id: 9, identificator: "Перерыв", start: "13:00", finish: "13:05", type: "pause" },
            { id: 10, identificator: "3 цикл", start: "13:05", finish: "13:40", type: "play" },
            { id: 11, identificator: "Перерыв", start: "13:40", finish: "13:45", type: "pause" },
            { id: 12, identificator: "4 цикл", start: "13:45", finish: "14:20", type: "play" },
            { id: 13, identificator: "Перерыв", start: "14:20", finish: "14:25", type: "pause" },
            { id: 14, identificator: "5 цикл", start: "14:25", finish: "15:00", type: "play" },
            { id: 15, identificator: "Подведение итогов", start: "15:00", finish: "15:30", type: "pause" }
          ]
        end
      end
    end
  end
end

