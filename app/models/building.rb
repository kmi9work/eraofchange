class Building < ApplicationRecord
  audited

  belongs_to :building_level
  belongs_to :settlement
  # Начисления влияния, привязанные к постройке (штраф за неоплаченную церковь:
  # entity — эта постройка). Нужны, чтобы при удалении церкви мастер мог решить,
  # удалять ли начисленное влияние (см. BuildingsController#destroy).
  has_many :influence_items, as: :entity

  before_create :set_first_year

  def set_first_year
    self.params['first_year'] = GameParameter.current_year
  end

  def upgrade! zodchiy_bonus
    level = self.building_level&.level
    if level < BuildingLevel::MAX_LEVEL
      next_level = level + 1
      required_building_type = self.building_level.building_type
      self.building_level = BuildingLevel.find_by(level: next_level, building_type: required_building_type)
      if self.building_level && self.save
        if zodchiy_bonus && next_level == 3
          (country || Country.current)&.council_players(Job::ZODCHIY)&.each do |player|
            player.modify_influence(Job::ZODCHIY_BONUS, "Бонус за постройки", @building) 
          end
        end
        # Крепость: об улучшении узнаёт мастер сражений (о постройке — Settlement#build).
        # Уведомление только в ветке успешного save: на максимальном уровне и при
        # ошибке сохранения уровень не менялся, событию не место.
        if self.building_level.building_type_id == BuildingType::DEFENCE
          NotificationRule.fortress_changed(self, :upgraded, previous_level: level)
        end
        return {building_level: self.building_level, msg: "Новый уровень постройки: #{self.building_level&.name}"}
      else
        return {building_level: nil, msg: "Внутренняя ошибка. #{self.building_level}, #{self.errors.inspect}"}
      end
    end
    return {building_level: nil, msg: "Уровень максимальный. Улучшить невозможно."}
  end

  # Государство постройки — государство региона её поселения
  def country
    settlement&.region&.country
  end


  def income
    self.building_level&.params&.dig("income").to_i
  end

  def pay_for_maintenance
    if is_paid
      self.params["paid"].delete(GameParameter.current_year)
      self.save
    else
      self.params["paid"].push(GameParameter.current_year)
      self.save
    end
  end

  def is_paid
    self.params["paid"].include?(GameParameter.current_year)
  end

  def fined
    self.params['fined']
  end

  # Церковь, построенную в текущем году, не штрафуют за неоплату этого года:
  # оплата поддержания начинается со следующего года — так же, как влияние за
  # новую церковь начисляется сразу (Player#influence_buildings считает
  # first_year == current_year эквивалентом оплаты).
  def built_this_year?
    params['first_year'].to_i == GameParameter.current_year
  end

  # Штраф получает митрополит ГОСУДАРСТВА, в котором стоит церковь (регион её
  # поселения), а не «текущее государство» сессии: при смене года цикл идёт по
  # церквям всех государств, и штраф чужой церкви доставался митрополиту того,
  # кто менял год.
  def fine
    return if built_this_year?

    country&.council_players(Job::METROPOLITAN)&.each do |player|
      player.modify_influence(Job::METROPOLITAN_PINE, "Штраф за неоплаченную церковь", self) 
    end
    self.params['fined'] = true
    self.save
  end
end