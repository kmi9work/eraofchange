class Country < ApplicationRecord
  # params:
  # embargo (bool)- Введено ли эмбарго в стране?
  # relations (interger) - уровень отношений с Русью от -2 до 2
	has_many :regions


  RUS = 1         #Русь
  HORDE = 2       #Большая орда
  LIVONIAN = 3    #Ливонский орден
  SWEDEN = 4      #Швеция
  LITHUANIA = 5   #Великое княжество литовское
  KAZAN = 6       #Казанское ханство
  CRIMEA = 7      #Крымское ханство


  def impose_embargo
    if self.params['embargo'] != nil
      self.params['embargo'] = true
      self.save
      {result: true, msg: "Эмбарго введено."}
    else
      {result: nil, msg: "Эта страна не может вводить эмбарго."}
    end
  end

  def lift_embargo
    if self.params['embargo'] != nil
      self.params['embargo'] = false
      self.save
      {result: false, msg: "Эмбарго снято."}
    else
      {result: nil, msg: "Эта страна не может снимать эмбарго."}
    end
  end

  def improve_relations
    if self.params['relations'] != nil
      if self.params['relations'].between?(-2,1)
        self.params['relations'] += 1
        self.save
      else
        "Дальше отношения улучшать нельзя."
      end
    else
      "С этой страной нельзя менять отношения."
    end
  end

  def degrade_relations
    if self.params['relations'] != nil
      if self.params['relations'].between?(-1,2)
        self.params['relations'] -= 1
        self.save
      else
        "Дальше отношения снижать нельзя."
      end
    else
      "С этой страной нельзя менять отношения."
    end
  end


  def capture(region, how) #1 - войной, 0 - миром
   region.country_id = self.id
    if how == 1
      region.params["public_order"] -= 3
    else
      region.params["public_order"] += 3
    end

    region.save
    {result: true, msg: "Регион присоединен"}
  end


end
