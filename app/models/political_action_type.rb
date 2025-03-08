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

  def go_to_people(success, options) #Торжественный выход к народу
    if success
      player = Player.find_by_id(options[:player_id])
      if player
        player.modify_influence(1)
      end
    end
  end

  def inferior_coins(success, options) #Чеканка неполноценной монеты
    player = Player.find_by_id(options[:player_id])
    regions = Country.find_by_id(Country::RUS).regions
    if player && regions
      if success
        player.modify_influence(2)
      else 
        player.modify_influence(-2)
        regions.each {|r| r.modify_public_order(-1)}
      end
    end
  end

  def convene_meeting(success, options) #Созвать вече
    player = Player.find_by_id(options[:player_id])
    regions = Country.find_by_id(Country::RUS).regions
    if player && regions
      if success
        player.modify_influence(3)
        regions.each {|r| r.modify_public_order(5)}
      else 
        player.modify_influence(-3)
      end
    end
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

  def take_bribe(success, options) #Взять мзду
    player = Player.find_by_id(options[:player_id])
    scope = Country.where.not(id: Country::RUS)
    offset = rand(scope.count)
    rand_country = scope.offset(offset).first
    if player && rand_country
      if success
        player.modify_influence(2)
      else 
        player.modify_influence(-3)
        rand_country.params["relations"] -= 1        
      end
    end
  end

  def equip_caravan(success, options) #Снарядить караван
    player = Player.find_by_id(options[:player_id])
    if player
      if success
        player.modify_influence(1)
      else
        player.modify_influence(-3)
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
        player.modify_influence(-2)
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
        player.modify_influence(-2)
        Player.find_by(job_id: Job::GRAND_PRINCE).modify_influence(-2)
      end
    end
  end

  def recruiting(success, options) #Набрать рекрутов
    player = Player.find_by_id(options[:player_id])
    if player
      if success
        player.modify_influence(3)
      else 
        player.modify_influence(-3)
        settlements = Player.find_by(job_id: Job::GRAND_PRINCE).settlements
        regions = Region.joins(:settlements).where(settlements: settlements).distinct
        regions.each{|r| r.modify_public_order(-5)}
      end
    end
  end

  def swamp_drainage(success, options) #Осушение болот
    if success
      player = Player.find_by_id(options[:player_id])
      if player
        player.modify_influence(1)
      end
    end
  end

  def contracts_brother(success, options) #Подряды свояку
    player = Player.find_by_id(options[:player_id])
    if player
      if success
        player.modify_influence(2)
      else 
        player.modify_influence(-2)
      end
    end
  end

  def city_improvement(success, options) #Улучшение города
    player = Player.find_by_id(options[:player_id])
    if player
      if success
        player.modify_influence(3)
      else 
        player.modify_influence(-3)
      end
    end
  end

  def sermon(success, options)#Проповедь
    if success
      player = Player.find_by_id(options[:player_id])
      region = Region.find_by_id(options[:region_id])
      if player && region
        player.modify_influence(1)
        region.modify_public_order(5)
      end
    end  
  end

  def eradicate_heresies(success, options) #Искоренить ереси
    player = Player.find_by_id(options[:player_id])
    scope = Region.all
    offset = rand(scope.count)
    rand_region = scope.offset(offset).first
    if player && rand_region
      if success
        player.modify_influence(2)
      else 
        player.modify_influence(-2)
        rand_region.modify_public_order(-5)
      end
    end
  end
    
  def call_unity(success, options) #Призыв к единству
    player = Player.find_by_id(options[:player_id])
    if player
      if success
        player.modify_influence(3)
        countries = Country.where(id: [Country::PERMIAN, Country::VYATKA,Country::RYAZAN, Country::TVER, Country::NOVGOROD])
        countries.each {|c| c.improve_relations}
      else 
        player.modify_influence(-3)
      end
    end
  end

  def regency(success, options) #Регентство
    if success
      player = Player.find_by_id(options[:player_id])
      if player 
        player.modify_influence(1)
      end
    end 
  end

  def fabricate_denunciation(success, options) #Сфабриковать донос
    player_1 = Player.find_by_id(options[:player_id])
    player_2 = Player.find_by_id(options[:player_id])
    if player_1 && player_2
      if success
        player_1.modify_influence(2)
        player_2.modify_influence(-2)
      else 
        player_1.modify_influence(-2)
      end
    end
  end

  def favoritism(success, options) #Фаворитизм
    player_1 = Player.find_by_id(options[:player_id])
    player_2 = Player.find_by_id(options[:player_id])
    if player_1 && player_2
      if success
        player_1.modify_influence(3)
        player_2.modify_influence(3)
      else 
        player_1.modify_influence(-3)
      end
    end
  end

  def development_farm(success, options) #Развитие хозяйства
    if success
      player = Player.find_by_id(options[:player_id])
      if player 
        player.modify_influence(1)
      end
    end 
  end

  def confused_his_with_state(success, options) #Спутал свое с государственным
    player = Player.find_by_id(options[:player_id])
    if player
      if success
        player.modify_influence(2)
      else 
        player_1.modify_influence(-3)
      end
    end
  end

  def patronage_gentiles(success, options) #Покровительство иноверцам
    player = Player.find_by_id(options[:player_id])
    regions = Country.find_by_id(Country::RUS).regions
    if player
      if success
        player.modify_influence(3)
      else 
        player_1.modify_influence(-3)
        regions.each {|r| r.modify_public_order(-3)}
      end
    end
  end
end
