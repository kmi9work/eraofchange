class Plant < ApplicationRecord
  belongs_to :plant_level, optional: true
  belongs_to :plant_place, optional: true
  belongs_to :economic_subject, polymorphic: true, optional: true
  
  def name_of_plant
    if economic_subject_type == "Guild"
      proprietor = "гильдии"
    else
      proprietor = "купца"
    end

    plant_name = "#{self.plant_level&.plant_type&.name}" + " #{proprietor}" + " #{self.economic_subject&.name}"
  end 

  def upgrade!
    level = self.plant_level&.level
    if self.plant_level&.level < 3
      pl = PlantLevel.find_by(level: level + 1, plant_type_id: self.plant_level.plant_type_id)
      self.plant_level = pl
      self.plant_level.save
      return self.plant_level.level
    end
  end

    # Чтобы метод можно было проверить - нужно для начала сохранить несколько PlantLevel.
    # Метод должен увеличивать уровень предприятия. 
    # Пример запуска (как должно быть):
    # plant = Plant.first
    # plant.plant_level.level
    # => 1
    # plant.upgrade!
    # plant.plant_level.level
    # => 2
    # Метод должен сменить plant_level на новый plant_level с более высоким уровнем того же типа, если он есть (plant_type_id).
    # Если удалось повысить уровень - вернуть в методе новый уровень. Если не удалось - метод должен вернуть nil.
  

  def pawn!
    # Заложить предприятие. Пометить предприятие как заложенное. Вывести стоимость.
  end

  def self.sell_plant(economic_subject, plant_place, plant_level, comment = "")
    # Создать новое предприятие у economic_subject в plant_place уровня plant_level.
    # Записать в него комментарий comment
    # Сохранить предприятие. 
    # Вернуть из метода хэш: 
    # {
    #   result: result,
    #   msg: msg
    # }
    # Если не удалось сохранить: result = nil, msg = ошибка сохранения
    # Если сохранилось: result = Созданное предприятие, msg = "Успешно"
    # Пример использования: Plant.sell_plant(Merchant.last, PlantPlace.last, PlantLevel.where(level: 1).first, "Предприятие")
  end
end
