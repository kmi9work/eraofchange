class Country < ApplicationRecord
  # params:
  # embargo (bool)- Введено ли эмбарго в стране?
	has_many :regions
  has_many :relation_items

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

  def change_relations(count, entity)
    count = count.to_i
    rel = relations
    r = rel + count
    comment = entity.is_a?(PoliticalAction) ? entity.political_action_type.name : entity.name
    RelationItem.add(
      (r / r.abs) * (count.abs - (r.abs - REL_RANGE)),
      comment,
      self,
      entity
    )
  end

  def relations
    self.params['relations'].to_i + relation_items.sum(&:value)
  end

  def capture(region, how) #1 - войной, 0 - миром
   region.country_id = self.id
    if how.to_i == BY_WAR
      region.params["public_order"] += MILITARILY
    elsif how.to_i == BY_DIPLOMACY
      region.params["public_order"] += PEACEFULLY
    end

    region.save
    {result: true, msg: "Регион присоединен к #{self.name}"}
  end
end
