class Building < ApplicationRecord
  belongs_to :building_level
  belongs_to :settlement

  def upgrade!
    level = self.building_level&.level
    if level < BuildingLevel::MAX_LEVEL
      next_level = level + 1
      required_building_type = self.building_level.building_type
      self.building_level = BuildingLevel.find_by(level: next_level, building_type: required_building_type)
      if self.building_level && self.save
        return {building_level: self.building_level, msg: "Новый уровень постройки: #{self.building_level&.name}"}
      else
        return {building_level: nil, msg: "Внутренняя ошибка. #{self.building_level}, #{self.errors.inspect}"}
      end
    end
    return {building_level: nil, msg: "Уровень максимальный. Улучшить невозможно."}
  end

  def income
    self.building_level&.params&.dig("income").to_i
  end

  def pay_for_maintenance
    if self.params["paid"].include?(GameParameter.current_year)
      {result: false, msg: "За эту здание уже внесены расходы"}
    else
      self.params["paid"].push(GameParameter.current_year)
      self.save
      {result: true, msg: "Расходы за здание внесены"}
    end
  end

end