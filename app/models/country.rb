class Country < ApplicationRecord
  # params:
  # embargo (bool)- Введено ли эмбарго в стране?
	has_many :regions
  has_many :relation_items
  has_many :armies

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

  def embargo(arg) #1 - эмбарго есть, 0 - эмбарго нет
    if self.params['embargo'] != nil
      self.params['embargo'] = arg.to_i > 0
      self.save
      self.params['embargo'] ? emb = "введено" : emb = "снято"
      {result: true, msg: "Эмбарго #{emb}."}
    else
      {result: nil, msg: "Эта страна не может вводить и снимать эмбарго."}
    end
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
   region.country_id = self.id
    if how.to_i == BY_WAR
      PublicOrderItem.add(MILITARILY, "Присоединение войной", region, nil)
    elsif how.to_i == BY_DIPLOMACY
      PublicOrderItem.add(MILITARILY, "Присоединение миром", region, nil)
    end

    region.save
  end

  def join_peace
    rus = Country.find_by_id(RUS)
    regions.each{|r| rus.capture(r, BY_DIPLOMACY)}
    Job.find_by_id(Job::POSOL).players.each do |player|
      player.modify_influence(Job::POSOL_BONUS, "Бонус за присоединение миром", self) 
    end
  end
end
