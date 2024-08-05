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
        {msg: "Размер вражеской армии: #{army.army_size&.name}. В нее входят: #{}."}         
      end
    end
  end

  def sabotage(success, options) #Саботаж
    if success
      army = Army.find_by_id(options[:army_id])
      if army
        army.params["palsy"] = true
        army.save      
      end
    end    
  end

  def contraband(success, options) #Контрабанда
    if success
      country = Country.find_by_id(options[:country_id])
      if country
      end
    end
  end

  def open_gate(success, options) #Открыть ворота!

  end

  def new_fisheries(success, options) #Новые промыслы
    
  end

end
