class Troop < ApplicationRecord
  belongs_to :troop_type
  belongs_to :army

  before_create :set_first_year

  RENEWAL_COST = 7000
  CANON_COST = [
    {identificator: "tools", count: 20}, 
    {identificator: "metal", count: 20}, 
    {identificator: "money", count: 1000}
  ]

  def set_first_year
    self.params['first_year'] = GameParameter.current_year
  end

  def pay_for
    if is_paid
      self.params["paid"].delete(GameParameter.current_year)
    else
      self.params["paid"].push(GameParameter.current_year)
    end
    self.save
  end

  def is_paid
    self.params["paid"]&.include?(GameParameter.current_year)
  end

  def power
    health
  end

  def health
    troop_type.params['max_health'].to_i - self.params['damage'].to_i
  end

  def max_health
    troop_type.params['max_health'].to_i
  end

  def damage
    self.params['damage'].to_i
  end

  def injure damage
    if damage >= health
      self.destroy
    else
      self.params['damage'] = damage
      self.save
    end
  end

  def to_destroy
    !self.params["paid"]&.include?(GameParameter.current_year - 1) && self.params['first_year'].to_i < GameParameter.current_year
  end
end
