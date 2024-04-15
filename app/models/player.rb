class Player < ApplicationRecord
  belongs_to :human, optional: true
  belongs_to :player_type, optional: true
  belongs_to :family, optional: true
  belongs_to :job, optional: true
  belongs_to :guild, optional: true

  has_many :plants, :as => :economic_subject,
           :inverse_of => :economic_subject
  has_many :settlements
  has_many :armies
  has_many :credits
  has_many :political_actions

  validates :name, presence: { message: "Поле Имя должно быть заполнено" }

  SMALL_ARMY = 1        #Малая армия
  MEDIUM_SIZE_ARMY = 2  #Средняя армия
  LARGE_ARMY = 3        #Большая армия
  PLAYABLE_REGION = 1



  def add_small_army
    army_type = ArmySize.find_by_id(SMALL_ARMY)
    Army.create(player_id: self.id, army_size: army_type, region_id: PLAYABLE_REGION)
  end

  def add_medium_size_army
    army_type = ArmySize.find_by_id(MEDIUM_SIZE_ARMY)
    Army.create(player_id: self.id, army_size: army_type, region_id: PLAYABLE_REGION)
  end

  def add_large_army
    army_type = ArmySize.find_by_id(LARGE_ARMY)
    Army.create(player_id: self.id, army_size: army_type, region_id: PLAYABLE_REGION)
  end

  def player_income
    income = 0
    added_income = 0
    self.settlements.each do |settle|
      income = income + settle.settlement_type.params["income"]
      settle.buildings.each do |build|
        if build.building_level.building_type == BuildingType.find_by_id(Settlement::TRADE_BUILDING)
          added_income = build.building_level.params["income"]
        end
      income = income + added_income
      end
    end
    income
  end

  def player_military_outlays
    gold_needed = 0
    rations_needed = 0
    arms_needed = 0
    armour_needed = 0
    horses_needed = 0
    self.armies.each do |army|
      gold_needed = gold_needed + army.army_size.params["gold"]
      rations_needed = rations_needed + army.army_size.params["rations"]
      arms_needed = arms_needed + army.army_size.params["arms"]
      armour_needed = armour_needed + army.army_size.params["armour"]
      horses_needed = horses_needed + army.army_size.params["horses"]
    end
    outlays = "Игрок должен внести за армии: золота #{gold_needed}, провизии #{rations_needed},
              оружия #{arms_needed}, доспехов #{armour_needed}, лошадей #{horses_needed}."
    outlays
  end


 end