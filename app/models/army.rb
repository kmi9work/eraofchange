class Army < ApplicationRecord
  belongs_to :region, optional: true
  belongs_to :player, optional: true
  belongs_to :army_size, optional: true

  has_many :troops, dependent: :destroy

  SMALL = 1    #Малая армия
  MEDIUM = 2   #Средняя армия
  LARGE = 3    #Большая армия

  def demote_army #Если за большую армию не вносятся расходы, она превращается в среднюю
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