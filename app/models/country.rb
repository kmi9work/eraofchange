class Country < ApplicationRecord
  audited
  
  # params:
  # embargo (bool)- Введено ли эмбарго в стране?
	has_many :regions
  has_many :relation_items
  has_many :armies
  has_many :caravans

  REL_RANGE = 2   # relations (interger) - уровень отношений с Русью от -2 до 2

  RUS = 1         #Русь
  HORDE = 2       #Большая орда
  LIVONIAN = 3    #Ливонский орден
  SWEDEN = 4      #Швеция
  LITHUANIA = 5   #Великое княжество литовское
  KAZAN = 6       #Казанское ханство
  CRIMEA = 7      #Крымское ханство

  PERMIAN = 8     #Пермь
  VYATKA = 9      #Вятка
  RYAZAN = 10     #Рязань
  TVER = 11       #Тверь
  NOVGOROD = 12   #Великий Новгород

  BY_WAR = 1
  BY_DIPLOMACY = 0

  MILITARILY = -3
  PEACEFULLY = 3

  scope :foreign_countries, -> {where(id: [HORDE, LIVONIAN, SWEDEN, LITHUANIA, KAZAN, CRIMEA])}

  def calculate_trade_turnover
    caravans = self.caravans
    trade_turnover = 0
    caravans.each {|car| trade_turnover += car.gold_from_pl + car.gold_to_pl}
    return trade_turnover
  end

  def embargo #1 - эмбарго есть, 0 - эмбарго нет
    params['embargo']
  end

  def set_embargo
    return false if params['embargo'].nil?
    self.params['embargo'] = params['embargo'] == 0 ? 1 : 0
    self.save
  end

  def change_relations(count, entity, comment = nil)
    count = count.to_i
    rel = relations
    r = rel + count
    if entity.is_a?(PoliticalAction)
      comment = entity.political_action_type&.name
    elsif comment.blank?
      comment = entity.try(:name)
    end
    RelationItem.add(
      r.abs > REL_RANGE ? ((r / r.abs) * (count.abs - (r.abs - REL_RANGE))) : count,
      comment,
      self,
      entity
    )
  end

  def relations
    sum = 0
    sum += 2 if (Technology.find(Technology::MOSCOW_THIRD_ROME).is_open == 1) && [PERMIAN, VYATKA, RYAZAN, TVER, NOVGOROD].include?(self.id)
    sum += relation_items.sum(&:value)
    sum.abs > REL_RANGE ? (sum / sum.abs)*[sum.abs, REL_RANGE].min : sum
  end

  def capture(region, how) #1 - войной, 0 - миром
    if region.country_id != self.id
     region.country_id = self.id
      if how.to_i == BY_WAR
        PublicOrderItem.add(MILITARILY, "Присоединение войной #{region.name}", region, nil)
      elsif how.to_i == BY_DIPLOMACY
        PublicOrderItem.add(PEACEFULLY, "Присоединение миром #{region.name}", region, nil)
      end

      if self.id == RUS
        Job.find_by_id(Job::GRAND_PRINCE).players.each do |player|
          player.modify_influence(Job::GRAND_PRINCE_BONUS, "Бонус за присоединение миром #{region.name}", self) 
        end
      end

      region.save
    end
  end

  def join_peace
    rus = Country.find_by_id(RUS)
    if regions.any?{|r| r.country_id != RUS}
      regions.each{|r| rus.capture(r, BY_DIPLOMACY)}
      Job.find_by_id(Job::POSOL).players.each do |player|
        player.modify_influence(Job::POSOL_BONUS, "Бонус за присоединение миром #{self.name}", self) 
      end
    end
  end
end
