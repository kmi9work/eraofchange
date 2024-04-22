class Plant < ApplicationRecord
  belongs_to :plant_level, optional: true
  belongs_to :plant_place, optional: true
  belongs_to :economic_subject, polymorphic: true, optional: true

  before_destroy :check_credit, prepend: true

  def check_credit
    if self.credit.present?
      self.errors.add(:credit, "Нельзя удалить предприятие, связанное с кредитом")
      throw :abort
    end
  end
  
  def name_of_plant
    if economic_subject_type == "Guild"
      proprietor = "гильдии"
    else
      proprietor = "купца"
    end

    plant_name = "#{@plant_type&.name}" + " #{proprietor}" + " #{economic_subject&.name}"
  end

  def upgrade!
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
  end
end
