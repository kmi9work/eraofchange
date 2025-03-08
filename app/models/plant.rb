class Plant < ApplicationRecord

  # params:
  # produced ([]) - Произведено

  audited
  belongs_to :plant_level, optional: true
  belongs_to :plant_place, optional: true
  belongs_to :economic_subject, polymorphic: true, optional: true
  belongs_to :credit, optional: true

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

    "#{@plant_type&.name} #{proprietor} #{economic_subject&.name}"
  end

  def upgrade!
    level = self.plant_level&.level
    if level && level < PlantLevel::MAX_LEVEL
      pl = PlantLevel.find_by(level: level + 1, plant_type_id: self.plant_level.plant_type_id)
      self.plant_level = pl
      if pl && self.save
        return {plant_level: pl, msg: "Уровень предприятия увеличен"}
      else
        return {plant_level: nil, msg: "Внутренняя ошибка. #{pl}, #{self.errors.inspect}"}
      end
    end
    return {plant_level: nil, msg: "Невозможно улучшить. Уровень предприятия максимальный"}
  end

  def has_produced!
    self.params["produced"].push(GameParameter.current_year)
    self.save
  end
end
