class Army < ApplicationRecord

  # params:
  # palsy ([]) - Паралич

  belongs_to :region, optional: true
  belongs_to :player, optional: true
  belongs_to :army_size, optional: true

  has_many :troops, dependent: :destroy

  def demote_army #Если за большую армию не вносятся расходы, она должна либо исчезнуть, либо ухудшиться
  end

  def has_empty_slots?
    number_of_slots = self.army_size&.params.dig("max_troop").to_i
    hired_troops = self.troops.count
    hired_troops < number_of_slots
  end

  def add_troop(troop_type_id)
    if has_empty_slots?
      troop = self.troops.create(troop_type_id: troop_type_id)
      {troop: troop, msg: "Отряд успешно добавлен в армию"}
    else
      {troop: nil, msg: "В армии превышено число отрядов"}
    end
  end
end
