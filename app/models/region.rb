class Region < ApplicationRecord
  # params:
  # public_order (integer) - Общественный порядок


  CAP_INF_ON_PO = 3 #Влияние захвата на общественный порядок

  belongs_to :country

  has_many :settlements
  has_many :armies
  has_many :plant_places

  def inf_buildings_on_po #Влияние зданий на общественной порадок
    bl_params = self.settlements.joins(buildings: :building_level).
         where(building_levels: {building_type_id: BuildingType::RELIGIOUS}).
         pluck('building_levels.params')
    po = bl_params.sum{|p| p["public_order"].to_i}

    ch_params = self.settlements.joins(buildings: :building_level).
        where(building_levels: {building_type_id: BuildingType::RELIGIOUS}).
        pluck('buildings.params')
    if ch_params.empty?
      inf = 0
    else
      for i in 0..ch_params.length-1
          if ch_params[i]["paid"].include?(GameParameter.current_year)
            inf = 3
          else
            inf = -3
            break
          end
      end
      po += inf
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
      self.params["public_order"] -= CAP_INF_ON_PO
    else
      self.params["public_order"] += CAP_INF_ON_PO
    end

    self.save
    {result: true, msg: "Регион присоединен"}
  end

end
