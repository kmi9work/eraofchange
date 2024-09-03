class Region < ApplicationRecord
  # params:
  # public_order (integer) - Общественный порядок



  belongs_to :country

  has_many :settlements
  has_many :armies
  has_many :plant_places

  def inf_buildings_on_po #Влияние зданий на общественной порадок
    bbl_params = self.settlements.joins(buildings: :building_level).
         where(building_levels: {building_type_id: BuildingType::RELIGIOUS}).
         pluck('buildings.params, building_levels.params')
    bbl_params.sum do |building_params, level_params| 
      if building_params['paid'].include?(GameParameter.current_year)
        level_params["public_order"].to_i
      else
        0
      end
    end
  end

  def inf_state_exp_on_po #Пересчет общественного порядка с учетом госрасходов
    if GameParameter.find_by(identificator: "current_year").params["state_expenses"]
      return 0
    else
      return -5
    end
  end

  def show_overall_po
    po = self.params["public_order"] #изначальный
    po += self.inf_buildings_on_po + self.inf_state_exp_on_po

    return po
  end

  def captured_by(who, how) #1 - войной, 0 - миром
    self.country_id = who
    if how == 1
      self.params["public_order"] -= Country::MILITARILY
    else
      self.params["public_order"] += Country::PEACEFULLY
    end

    self.save
    {result: true, msg: "Регион присоединен"}
  end

end
