class Building < ApplicationRecord
  audited

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
    if is_paid
      self.params["paid"].delete(GameParameter.current_year)
      self.save
    else
      self.params["paid"].push(GameParameter.current_year)
      self.save
    end
  end

  def is_paid
    self.params["paid"].include?(GameParameter.current_year)
  end

  def fined
    self.params['fined']
  end

  def fine
    Job.find_by_id(Job::METROPOLITAN).players.each do |player|
      player.modify_influence(Job::METROPOLITAN_PINE, "Штраф за неоплаченную церковь", self) 
    end
    self.params['fined'] = true
    self.save
  end
end