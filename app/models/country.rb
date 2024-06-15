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
    else
      "Эта страна не может вводить эмбарго."
    end
  end

  def lift_embargo
    if self.params['embargo'] != nil
      self.params['embargo'] = false
      self.save
    else
      "Эта страна не может снимать эмбарго."
    end
  end

  def embargo_switcher
    if self.params['embargo'] != nil
      if self.params['embargo'] == true
        self.params['embargo'] = false
      else
        self.params['embargo'] = true
      end
    else
    "Эта страна не может снимать или вводить эмбарго."
    end
  end

  def relations_improver
    if self.params['relations'] != nil
      if self.params['relations'].between?(-2,1)
        self.params['relations'] += 1
        self.save
      else
        "Дальше отношения улучшать нельзя."
      end
    else
      "С этой страной нельзя меня отношения."
    end
  end

  def relations_degrador
    if self.params['relations'] != nil
      if self.params['relations'].between?(-1,2)
        self.params['relations'] -= 1
        self.save
      else
        "Дальше отношения снижать нельзя."
      end
    else
      "С этой страной нельзя меня отношения."
    end
  end

end
