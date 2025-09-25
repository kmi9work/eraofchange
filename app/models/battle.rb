class Battle < ApplicationRecord
  audited
  
  belongs_to :attacker_army, class_name: 'Army', optional: true
  belongs_to :defender_army, class_name: 'Army', optional: true
  belongs_to :winner_army, class_name: 'Army', optional: true
  
  validates :damage, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :year, presence: true, numericality: { greater_than: 0 }
  
  def attacker_name
    attacker_army_name || attacker_owner_name || attacker_army&.name || attacker_army&.owner&.name || 'Неизвестный'
  end
  
  def defender_name
    defender_army_name || defender_owner_name || defender_army&.name || defender_army&.owner&.name || 'Неизвестный'
  end
  
  def winner_name
    winner_army_name || winner_owner_name || winner_army&.name || winner_army&.owner&.name || 'Неизвестный'
  end
  
  def loser_name
    winner_army == attacker_army ? defender_name : attacker_name
  end
end
