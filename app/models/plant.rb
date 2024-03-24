class Plant < ApplicationRecord
  belongs_to :settlement, optional: true
  belongs_to :economic_subject, polymorphic: true, optional: true
  belongs_to :plant_category, optional: true
  belongs_to :plant_type, optional: true
  
  def name_of_plant
    if economic_subject_type == "Guild"
      proprietor = "гильдии"
    else
      proprietor = "купца"
    end

    plant_name = "#{plant_type&.name}" + " #{proprietor}" + " #{economic_subject&.name}"
  end

  def upgrade!
    # Нужно для начала сохранить несколько PlantLevel.
    # Метод должен увеличивать уровень предприятия. Сменить plant_level на более высокий того же типа, если он есть (plant_type_id).
    # Если удалось повысить уровень - вернуть в методе новый уровень. Если не удалось - метод должен вернуть nil.
  end

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
