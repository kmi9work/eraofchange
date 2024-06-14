class PlantLevel < ApplicationRecord
    belongs_to :plant_type, optional: true

    has_many :plants

    MAX_LEVEL = 3
      
  # Общая структура формулы производства:
  # formula: {
  #   from: [
  #     {resource_id: id, count: 1}, ...
  #   ],
  #   to: [
  #     {resource_id: id, count: 2}, ...
  #   ],
  #   max: [
  #     {resource_id: id, count: 100}, ...
  #   ]
  # }
  # 
  # Пример 1: из 6 досок(id 1) и 1 металла (id 2) и 300 золота (id 3) сделать один инструмент (id 10):
  # formula: {
  #   from: [
  #     {resource_id: 1, count: 6},
  #     {resource_id: 2, count: 1},
  #     {resource_id: 3, count: 300}
  #   ],
  #   to: [
  #     {resource_id: 10, count: 1}
  #   ],
  #   max: [
  #     {resource_id: 10, count: 20}
  #   ]
  # }
  # 
  # Пример 2: Добывающая делянка первого уровня (оплата 100 золота, производство 100 дерева id 4):
  # formula: {
  #   from: [
  #     {resource_id: 3, count: 100}
  #   ],
  #   to: [
  #     {resource_id: 4, count: 100}
  #   ],
  #   max: [
  #     {resource_id: 4, count: 100}
  #   ]
  # }

  def produce(resources_from, resources_expect = nil)
    # Необходимо осуществить производство ресурса в соответствии с формулой, хранящейся в классе.
    # Если есть ожидаемые ресурсы (например, в Кузнице) Проверяется - возможно ли произвести ожидаемые ресурсы. То, что не получается по формуле или выше максимума - вернуть в сдачу. 
    # Если resources_expect.blank? то нужно посчитать сколько можно произвести ресурсов из resources_from (в кузнице тогда производить в первую очередь инструменты, потом оружие, на оставшиеся - доспехи)
    # Пример работы:
    # pl = PlantLevel.last
    # pl.produce([
    #   {resource_id: 1, count: 60},
    #   {resource_id: 2, count: 10},
    #   {resource_id: 3, count: 300}
    # ])
    # => 
    # [{resource_id: 10, count: 10}]

    # Другой пример (допустим, инструменты производятся из 6 досок и одного металла, а одни доспехи (id 11) из 5 металла)
    # Запрос - 10 инструмента и один доспех. Ресурсы 60 досок, 20 металла и 300 монет
    # Тогда программа должна выдать 10 инструментов, один доспех и 5 металла сдачи
    # pl.produce([
    #   {resource_id: 1, count: 60},
    #   {resource_id: 2, count: 20},
    #   {resource_id: 3, count: 300}
    # ], [
    # {resource_id: 10, count: 10},
    # {resource_id: 11, count: 1}
    # ])
    # => 
    # [{resource_id: 10, count: 10}, {resource_id: 11, count: 1}, {resource_id: 2, count: 5}]
  end
end
