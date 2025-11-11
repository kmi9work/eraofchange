# EXAMPLE: Это шаблонный файл для создания своего Engine
module VassalsAndRobbers
  module Concerns
    module GameParameterExtensions
      extend ActiveSupport::Concern

      included do
        # В игре Vassals and Robbers циклы запускаются автоматически
        self.auto_start_next_cycle = true

        module DefaultScheduleOverride
          def default_schedule
            [
              { id: 1, identificator: "Регистрация игроков", start: "12:20", finish: "12:30", type: "pause" },
              { id: 2, identificator: "Инструктаж", start: "12:30", finish: "13:00", type: "pause" },
              { id: 3, identificator: "1 цикл", start: "13:00", finish: "13:50", type: "play" },
              { id: 4, identificator: "Перерыв", start: "13:50", finish: "13:55", type: "pause" },
              { id: 5, identificator: "2 цикл", start: "13:55", finish: "14:30", type: "play" },
              { id: 6, identificator: "Перерыв", start: "14:30", finish: "14:35", type: "pause" },
              { id: 7, identificator: "3 цикл", start: "14:35", finish: "15:10", type: "play" },
              { id: 8, identificator: "Перерыв", start: "15:10", finish: "15:15", type: "pause" },
              { id: 9, identificator: "4 цикл", start: "15:15", finish: "15:50", type: "play" },
              { id: 10, identificator: "Перерыв", start: "15:50", finish: "15:55", type: "pause" },
              { id: 11, identificator: "5 цикл", start: "15:55", finish: "16:30", type: "play" },
              { id: 12, identificator: "Подведение итогов игры", start: "16:30", finish: "17:00", type: "pause" },
              { id: 13, identificator: "Обсуждение", start: "17:00", finish: "18:00", type: "pause" }
            ]
          end

          def vassals_schedule
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

        singleton_class.prepend(DefaultScheduleOverride)
      end
    end
  end
end

