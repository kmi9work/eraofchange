class Country < ApplicationRecord
  # params:
  # embargo (bool)- Введено ли эмбарго в стране?
	has_many :regions

  REL_RANGE = 2   # relations (interger) - уровень отношений с Русью от -2 до 2

  RUS = 1         #Русь
  HORDE = 2       #Большая орда
  LIVONIAN = 3    #Ливонский орден
  SWEDEN = 4      #Швеция
  LITHUANIA = 5   #Великое княжество литовское
  KAZAN = 6       #Казанское ханство
  CRIMEA = 7      #Крымское ханство

  BY_WAR = 1
  BY_DIPLOMACY = 0

  MILITARILY  = -3
  PEACEFULLY = 3

  def embargo(arg) #1 - снято, -1 - введено
    if self.params['embargo'] != nil
      self.params['embargo'] = arg.to_i >= 0
      self.save
      self.params['embargo'] ? emb = "введено" : emb = "снято"
     {result: true, msg: "Эмбарго #{emb}."}
    else
      {result: nil, msg: "Эта страна не может вводить и снимать эмбарго."}
    end
  end

  def change_relations(arg)
    pos_or_neg_inc = arg.to_i.positive? ? 1 : -1
    if self.params['relations'] != nil
      if (self.params['relations'] + pos_or_neg_inc).abs <= REL_RANGE
        self.params['relations'] += pos_or_neg_inc
        self.save
      else
        "Дальше отношения улучшать нельзя."
      end
    else
      "С этой страной нельзя менять отношения."
    end
  end

  def capture(region, how) #1 - войной, 0 - миром
   region.country_id = self.id
    if how.to_i == BY_WAR
      region.params["public_order"] += MILITARILY
    elsif how.to_i == BY_DIPLOMACY
      region.params["public_order"] += PEACEFULLY
    end

    region.save
    {result: true, msg: "Регион присоединен к #{self.title}"}
  end
end
