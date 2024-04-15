class Army < ApplicationRecord
  belongs_to :region, optional: true
  belongs_to :player, optional: true
  belongs_to :army_size, optional: true

  has_many :troops, dependent: :destroy



  CROSSBOWMEN = 1     #Арбалетчики
  LIGHT_CAVALRY = 2   #Легкая кавалерия
  HEAVY_CAVALRY = 3   #Тяжелая кавалерия
  LIGHT_INFANTRY = 4  #Легкая пехота
  ARCHERS = 5         #Лучники
  MILITIA_MEN = 6     #Ополчение
  FOOT_KIGHTS = 7     #Пешие рыцари
  CANONS = 8          #Пушки
  KNIGHTS = 9         #Рыцари
  STEPPE_ARCHERS = 10 #Степные лучники
  STRELTSY = 11       #Стрельцы
  BATTERING_RAM = 12  #Таран

  def demote_army #Если за большую армию не вносятся расходы, она превращается в среднюю
  end

  def max_troops_checker
    number_of_slots =  self.army_size.params["max_troop"]
    hired_troops = 0
    self.troops.each do |troop|
      hired_troops += 1
    end
    if hired_troops <= number_of_slots
      slots_present = true
    else
      slots_present = false
    end
    slots_present
  end

  def add_crossbowmen
    slots_present = self.max_troops_checker
    if slots_present == true
      Troop.create(army_id: self.id, troop_type_id: CROSSBOWMEN)
    else
      puts "В армии превышено число отрядов"
    end
  end

  def add_light_cavalry
    slots_present = self.max_troops_checker
    if slots_present == true
      Troop.create(army_id: self.id, troop_type_id: LIGHT_CAVALRY)
    else
      puts "В армии превышено число отрядов"
    end
  end

  def add_heavy_cavalry
    slots_present = self.max_troops_checker
    if slots_present == true
      Troop.create(army_id: self.id, troop_type_id:  HEAVY_CAVALRY)
    else
      puts "В армии превышено число отрядов"
    end
  end


end