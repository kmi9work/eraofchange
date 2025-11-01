class Country < ApplicationRecord
  audited
  
  # params:
  # embargo (bool)- Введено ли эмбарго в стране?
	has_many :regions
  has_many :relation_items
  has_many :armies
  has_many :caravans
  has_many :alliances
  has_many :partner_alliances, class_name: 'Alliance', foreign_key: 'partner_country_id'

  REL_RANGE = 2   # relations (interger) - уровень отношений с Русью от -2 до 2
  
  # Бонус от технологии "Москва — Третий Рим" (можно переопределить в плагинах)
  class_attribute :moscow_third_rome_bonus, default: 2
  
  # Функционал управления союзами (можно включить в плагинах)
  class_attribute :alliances_enabled, default: false

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

  def show_current_trade_level
    # level_thresholds хранится в params
    levels = self.params&.dig("level_thresholds") || []
    return { current_level: 0, threshold: 0, to_next_level: 0 } if levels.empty?
    
    current_trade_turnover = self.calculate_trade_turnover[:trade_turnover] || 0
    
    # Находим текущий уровень: максимальный уровень, порог которого <= товарооборота
    current_level_info = levels.reverse.find { |lev| lev["threshold"].to_i <= current_trade_turnover }
    
    # Если не найден (товарооборот меньше первого порога), берём первый уровень
    if current_level_info.nil?
      current_level_info = levels.first
      current_level_number = 0
      next_level_info = levels.first
    else
      current_level_number = current_level_info["level"]
      # Находим следующий уровень
      next_level_info = levels.find { |lev| lev["level"] > current_level_number }
      
      # Если следующего уровня нет (достигнут максимум), используем текущий
      next_level_info ||= current_level_info
    end
    
    to_next_level = next_level_info["threshold"].to_i - current_trade_turnover
    to_next_level = 0 if to_next_level < 0
    
    return {
      current_level: current_level_number,
      threshold: next_level_info["threshold"],
      to_next_level: to_next_level
    }
  end

  def self.show_trade_turnover
    foreign_countries = Country.foreign_countries
    overall_trade_turnover = foreign_countries.map do |f_c|
      car_data = f_c.calculate_trade_turnover
      {country_id:    f_c.id,
      country_name:   f_c.name,
      trade_turnover: car_data[:trade_turnover],
      car_count:      car_data[:num_of_car],
      relations:      f_c.relations}
    end

    return overall_trade_turnover
  end

  def calculate_trade_turnover
    caravans = self.caravans || []
    trade_turnover = 0
    caravans.each {|car| trade_turnover += (car.gold_from_pl || 0) + (car.gold_to_pl || 0)}
    return {trade_turnover: trade_turnover || 0, num_of_car: caravans.count}
  end

  def embargo #1 - эмбарго есть, 0 - эмбарго нет
    params['embargo']
  end

  def set_embargo
    return false if params['embargo'].nil?
    self.params['embargo'] = params['embargo'] == 0 ? 1 : 0
    self.save
  end

  def improve_relations_via_trade
    current_params = self.params || {}
    relation_points = current_params['relation_points'].to_i
    
    # Проверяем, что есть relation_points для траты
    if relation_points < 1
      return { success: false, error: 'Недостаточно торговых очков (relation_points)' }
    end
    
    # Уменьшаем relation_points на 1
    current_params['relation_points'] = relation_points - 1
    self.params = current_params
    
    # Улучшаем отношения на 1
    change_relations(1, self, "Улучшение через торговлю")
    
    # Сохраняем изменения
    if self.save
      { success: true, new_relations: self.relations, relation_points_left: current_params['relation_points'] }
    else
      { success: false, error: self.errors.full_messages.join(', ') }
    end
  rescue => e
    { success: false, error: e.message }
  end

  def change_relations(count, entity, comment = nil)
    return "НЕЛЬЗЯ" if GameParameter.any_lingering_effects?("support_export") 
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
    sum += self.class.moscow_third_rome_bonus if (Technology.find(Technology::MOSCOW_THIRD_ROME).is_open == 1) && [PERMIAN, VYATKA, RYAZAN, TVER, NOVGOROD].include?(self.id)
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
