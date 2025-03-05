class PoliticalActionType < ApplicationRecord
  SEDITION_PO = 5
  CHARITY_PO = 5

  belongs_to :job
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
        current_year = GameParameter.find_by(identificator: "current_year")&.value.to_i
        army.params["palsy"].push(current_year + 1)
        #!!! Дописать в место, где есть передвижение армии - что двигать нельзя, если паралич
        army.save       
      end
    end    
  end

  def contraband(success, options) #Контрабанда
    # В options[:country_id] должна лежать страна контрабанды
    if success
      player = Player.find_by_id(options[:player_id])
      country = Country.find_by_id(options[:country_id])
      if player && country
        player.params["contraband"].push(country.title)
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
  
  end

  def send_embassy(success, options) #Отправить посольство
    if success
      player = Player.find_by_id(options[:player_id])
      countries = Country.find_by_id(options[:country_ids])
      if player && countries
        player.modify_influence(1)
        countries.each {|c| c.improve_relations}
      end
    end
  end

  def equip_caravan(success, options) #Снарядить караван
    player = Player.find_by_id(options[:player_id])
    if player
      if success
        player.modify_influence(2)
      else
        player.modify_influence(-2)
      end
    end   
  end

  def take_bribe(success, options) #Взять мзду
    player = Player.find_by_id(options[:player_id])
    scope = Country.where.not(id: Country::RUS)
    offset = rand(scope.count)
    rand_country = scope.offset(offset).first

    if player && country
      if success
        player.modify_influence(1)
      else 
        player.modify_influence(-3)
        country.modify_public_order(-1)
      end
    end
  end

  def сonduct_audit(success, options) #Провести ревизию
    if success
      player = Player.find_by_id(options[:player_id])
      if player
        player.modify_influence(1)
      end
    end
  end

  def peculation(success, options) #Казнокрадство
    player = Player.find_by_id(options[:player_id])
    if player
      if success
        player.modify_influence(2)
      else 
        player.modify_influence(-3)
      end
    end
  end

  def disperse_bribery(success, options) #Разогнать мздоимцев
    player = Player.find_by_id(options[:player_id])
    regions = Country.find_by_id(Country::RUS).regions
    if player && regions
      if success
        player.modify_influence(3)
      else
        player.modify_influence(-3)
        regions.each {|r| r.modify_public_order(-5)}
      end 
    end
  end

  def implement_sabotage(success, options) #Осуществить саботаж
    if success
      player = Player.find_by_id(options[:player_id])
      if player
        player.modify_influence(1)
      end
    end
  end

  def name_of_grand_prince(success, options) #Именем Великого князя!
    player = Player.find_by_id(options[:player_id])
    if player
      if success
        player.modify_influence(1)
      else
        player.modify_influence(-5)
        Player.find_by_id(job_id: Job::GRAND_PRINCE).modify_influence(-3)
      end
    end
  end

  def recruiting(success, options) #Набрать рекрутов (TODO: доделать)
    player = Player.find_by_id(options[:player_id])
    if player
      if success
        player.modify_influence(3)
      else 
        player.modify_influence(-3)
      end
    end
  end

  def mobile_court(success, options) #Выездной суд
    if success
      region = Region.find_by_id(options[:region_id])
      player = Player.find_by_id(options[:player_id])
      if region && player
        region.modify_public_order(5)
        player.modify_influence(1)
      end
    end
  end

  def fabricate_denunciation(success, options) #Сфабриковать донос
  end

  def legislative_reform(success, options)#Законодательная реформа
  end

  def sermon(success, options)#Проповедь    
  end

  def eradicate_heresies(success, options) #Искоренить ереси
  end

  def call_unity(success, options) #Призыв к единству
  end

  def regency(success, options) #Регентство
  end

  def use_seal(success, options) #Использовать великокняжескую печать
  end

  def favoritism(success, options) #Фаворитизм
  end

  def development_farm(success, options) #Развитие хозяйства
  end

  def confused_his_with_state(success, options) #Спутал свое с государственным
  end

  def patronage_gentiles(success, options) #Покровительство иноверцам
  end
end
