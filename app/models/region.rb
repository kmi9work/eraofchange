class Region < ApplicationRecord
  # params:
  # public_order (integer) - Общественный порядок
  audited

  belongs_to :country
  belongs_to :player, optional: true

  has_many :settlements
  has_many :armies
  has_many :plant_places
  has_many :public_order_items

  has_one :capital, -> { where(settlement_type_id: SettlementType::CAPITAL) }, class_name: 'Settlement'

  def inf_buildings_on_po #Влияние зданий на общественной порадок
    bbl_params = self.settlements.joins(buildings: :building_level).
         where(building_levels: {building_type_id: BuildingType::RELIGIOUS}).
         pluck('buildings.params, building_levels.params')
    bbl_params.sum do |building_params, level_params| 
      level_params["public_order"].to_i
    end
  end

  def count_items
    public_order_items.sum(&:value)
  end

  def show_overall_po
    self.inf_buildings_on_po + self.count_items
  end

  def captured_by(who_id, how) #1 - войной, 0 - миром
    self.country_id = who_id.to_i
    if who_id.to_i == Country::RUS
      if how.to_i == 1
        self.public_order_items << PublicOrderItem.add(Country::MILITARILY, "Регион присоединен войной", self)
      else
        self.public_order_items << PublicOrderItem.add(Country::PEACEFULLY, "Регион присоединен миром", self)
      end
    else
      self.settlements.update_all(player_id: nil)
    end
    self.save

    {result: true, msg: "Регион присоединен"}
  end
end
