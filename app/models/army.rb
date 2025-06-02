class Army < ApplicationRecord
  # params:
  # palsy ([]) - Паралич
  audited
  
  has_many   :troops, dependent: :destroy
  belongs_to :settlement, optional: true
  belongs_to :owner, polymorphic: true, optional: true

  NUMBER_OF_SLOTS = 3

  def has_empty_slots?
    number_of_slots = NUMBER_OF_SLOTS
    hired_troops = self.troops.count
    hired_troops < number_of_slots
  end

  def add_troop(troop_type_id)
    if has_empty_slots?
      troop = self.troops.create(troop_type_id: troop_type_id, params: {'paid' => []})
      {troop: troop, msg: "Отряд успешно добавлен в армию"}
    else
      {troop: nil, msg: "В армии превышено число отрядов"}
    end
  end

  def goto settlement_id
    settlement = Settlement.find_by_id(settlement_id)
    if settlement
      self.settlement_id = settlement.id
      self.save
    end
  end

  def power
    troops.sum{|t| t.power}
  end

  def attack enemy_id, voevoda_bonus
    enemy = Army.find_by_id(enemy_id)
    if enemy
      winner, looser = self.power > enemy.power ? [self, enemy] : [enemy, self]
      damage = (looser.power / 2.0).ceil
      winner.troops.shuffle.each do |troop|
        h = troop.health
        troop.injure(damage)
        damage -= h
        break if damage <= 0
      end
      looser.destroy
      if winner.owner.try(:job_ids)&.include?(Job::VOEVODA) or winner.owner.try(:job_ids)&.include?(Job::GRAND_PRINCE)
        Job.find_by_id(Job::VOEVODA).players.each do |player|
          player.modify_influence(Job::VOEVODA_BONUS, "Бонус за победу", winner) 
        end
      end
      winner
    else
      false
    end
  end
end
