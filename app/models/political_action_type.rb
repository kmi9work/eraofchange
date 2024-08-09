class PoliticalActionType < ApplicationRecord
  SEDITION_PO = 5
  CHARITY_PO = 5

  has_many :political_actions, dependent: :destroy

  def execute(success, options)
    if self.respond_to?(self.action)
      self.send(self.action, success, options)
    end
  end

  def sedition(success, options) #Подстрекательство к бунту
    if success
      region = Region.find_by_id(options[:region_id])
      if region
        region.params["public_order"] -= SEDITION_PO
        region.save
      end
    end
  end

  def charity(success, options) #Благотворительность
    if success
      region = Region.find_by_id(options[:region_id])
      if region
        region.params["public_order"] += CHARITY_PO
        region.save
      end
    end
  end

  def espionage(success, options) #Шпионаж
    if success
      army = Army.find_by_id(options[:army_id])
      if army
        army_size = army.army_size&.name
        troops = army.troops.joins(:troop_type).pluck('troops.troop_type_id, troop_types.title')
        final_hash = {
          army_size: army_size,
          troops: troops
        }
        return {result: final_hash}     
      end
    end
  end

  def sabotage(success, options) #Саботаж
    if success
      army = Army.find_by_id(options[:army_id])
      if army
        current_year = GameParameter.find_by(identificator: "current_year").value.to_i
        army.params["palsy"].push(current_year + 1)
        #!!! Дописать в место, где есть передвижение армии - что двигать нельзя, если паралич
        army.save     
      end
    end    
  end

  def contraband(success, options) #Контрабанда
    # В params должен лежать страна контрабанды
    if success
      player = Player.find_by_id(options[:player_id])
      if player
        country = Country.find_by_id(options[:country_id]).title
        player.params["contraband"].push(country)
        player.save
      end
    end
  end

  def open_gate(success, options) #Открыть ворота!
    if success
      settlement = Settlement.find_by_id(options[:settlement_id])
      if settlement
        settlement.params["open_gate"] = true
        settlement.save
      end
    end
  end

  def new_fisheries(success, options) #Новые промыслы
    player = Player.find_by_id(options[:player_id])
    if success
    end    
  end

end
