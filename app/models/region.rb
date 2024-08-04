class Region < ApplicationRecord
  # params:
  # public_order (integer) - Общественный порядок

  belongs_to :country

  has_many :settlements
  has_many :armies

  def inf_buildings_on_po #Влияние зданий на общественной порадок
    bl_params = self.settlements.joins(buildings: :building_level).
         where(building_levels: {building_type_id: BuildingType::RELIGIOUS}).
         pluck('building_levels.params')
    bl_params.sum{|p| p["public_order"].to_i}
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

end
