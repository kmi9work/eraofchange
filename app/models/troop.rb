class Troop < ApplicationRecord
  belongs_to :troop_type
  belongs_to :army

  RENEWAL_COST = 7000
  CANON_COST = [
    {identificator: "tools", count: 20}, 
    {identificator: "metal", count: 20}, 
    {identificator: "money", count: 1000}
  ]

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
end
