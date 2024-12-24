class Army < ApplicationRecord

  # params:
  # palsy ([]) - Паралич

  belongs_to :region, optional: true
  belongs_to :player, optional: true
  belongs_to :army_size, optional: true

  def demote_army! #Если за большую армию не вносятся расходы, она должна либо исчезнуть, либо ухудшиться
    if self.army_size_id == ArmySize::SMALL
      self.destroy
      {result: true, msg: "Армия удалена за неуплату"}
    elsif self.army_size_id == ArmySize::MEDIUM
      self.army_size_id = ArmySize::SMALL
      self.save
      {result: true, msg: "Армия сокращена за неуплату"}
    elsif self.army_size_id == ArmySize::LARGE
      self.army_size_id = ArmySize::MEDIUM
      self.save
      {result: true, msg: "Армия сокращена за неуплату"}
    end
  end

  def check_and_demote_army!
    # если на конец года оплачено, то не надо, в противном случае -- распустить
    if !self.params["paid"].include?(GameParameter.current_year)
      demote_army!
    end
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

  def pay_for_army
    if self.params["paid"].include?(GameParameter.current_year)
      {result: false, msg: "Армия в этом году уже оплачена"}
    else
      self.params["paid"].push(GameParameter.current_year)
      self.save
      {result: true, msg: "Армия оплачена"}
    end
  end


end
