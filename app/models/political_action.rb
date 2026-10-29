class PoliticalAction < ApplicationRecord
  audited

  belongs_to :player
  belongs_to :job
  belongs_to :political_action_type
  belongs_to :guild, optional: true
  # Действия считаются в разрезе государства (каталог типов действий общий)
  belongs_to :country, optional: true

  before_validation :assign_default_country

  scope :for_country, ->(country) { country.nil? ? all : where(country_id: country.id) }
  scope :for_year, ->(year) { year.nil? ? all : where(year: year) }

  # Государства, с которыми «Взять мзду» отношения НЕ портит (решение заказчика):
  # Москва и Новгород. Своё государство дьяка тоже исключается — отношений с самим
  # собой нет.
  TAKE_BRIBE_EXCLUDED_COUNTRIES = [Country::RUS, Country::NOVGOROD].freeze

  def execute
    action_name = self.political_action_type&.action
    if respond_to?(action_name)
      send(action_name)
    end
    self.save
  end

  # ------- Купцы --------

  def sedition #Подстрекательство к бунту
  end

  def charity #Благотворительность
  end

  def sabotage #Саботаж
  end

  def contraband #Контрабанда
    if success.to_i == 1
      guild&.grant_contraband_card(GameParameter.current_year)
    end
  end

  def open_gate #Открыть ворота!
  end

  def new_fisheries #Новые промыслы
  end

  def people_support #Народная поддержка
  end

  # =========== /Купцы ===========

  def ceremonial #Торжественный выход к народу
    if success.to_i == 1
      modify_influence(1)
    end
  end

  def defective_coin #Чеканка неполноценной монеты
    if success.to_i == 1
      modify_influence(2)
    else 
      modify_influence(-2)
      regions = Country.current.regions
      regions.each {|r| PublicOrderItem.add(-1, self.political_action_type.name, r, self)}
    end
  end

  def call_a_meeting #Созвать вече
    if success.to_i == 1
      regions = Country.current.regions
      modify_influence(3)
      regions.each {|r| PublicOrderItem.add(5, self.political_action_type.name, r, self)}
    else 
      modify_influence(-3)
    end
  end 

  # «Отправить посольство»: посольство уходит в ДВЕ державы (карточка действия —
  # «улучшение отношений с 2-мя выбранными иностранными державами на 1 пункт»),
  # отношения с каждой +1. Параметры — два скаляра: `country_id` и `country_id_2`
  # (Rails `permit(params: {})` пропускает только скаляры, массив молча терялся бы).
  # Если пришла одна страна (старый клиент) — работает как раньше.
  def send_embassy #Отправить посольство
    if success.to_i == 1
      modify_influence(1)
      embassy_countries.each { |country| country.change_relations(1, self) }
    end
  end

  def take_bribe #Взять мзду
    if success.to_i == 1
      modify_influence(2)
    else 
      modify_influence(-3)
      rand_country = take_bribe_random_country
      if rand_country
        rand_country.change_relations(-1, self)
        # Выбор сервера пишем в params: клиент показывает мастерам, с кем именно
        # испортились отношения, а история действия остаётся проверяемой.
        self.params = (params || {}).merge('country_id' => rand_country.id)
      end
    end
  end

  def equip_caravan #Снарядить караван
    if success.to_i == 1
      modify_influence(1)
    else
      modify_influence(-3)
    end
  end

  def conduct_audit #Провести ревизию
    if success.to_i == 1
      modify_influence(1)
    end
  end

  def peculation #Казнокрадство
    if success.to_i == 1
      modify_influence(2)
    else 
      modify_influence(-2)
    end
  end

  def disperse_bribery #Разогнать мздоимцев
    if success.to_i == 1
      modify_influence(3)
    else
      modify_influence(-3)
      regions = Country.current.regions
      regions.each {|r| PublicOrderItem.add(-5, self.political_action_type.name, r, self)}
    end 
  end

  def implement_sabotage #Осуществить саботаж
    if success.to_i == 1
      modify_influence(1)
    end
  end

  def name_of_grand_prince #Именем Великого князя!
    if success.to_i == 1
      modify_influence(1)
    else
      modify_influence(-2)
      princes = Country.current.council_players(Job::GRAND_PRINCE)
      princes.each{|p| InfluenceItem.add(-2, self.political_action_type.name, p, self)}
    end
  end

  def recruiting #Набрать рекрутов
    if success.to_i == 1
      modify_influence(3)
    else 
      modify_influence(-3)
      prince_ids = Country.current.council_players(Job::GRAND_PRINCE).pluck(:id)
      regions = Region.joins(settlements: :player).where(settlements: {player_id: prince_ids}).distinct
      regions.each{|r| PublicOrderItem.add(-5, self.political_action_type.name, r, self)}
    end
  end

  def drain_the_swamps #Осушение болот
    if success.to_i == 1
      modify_influence(1)
    end
  end

  def contract_to_cousin #Подряды свояку
    if success.to_i == 1
      modify_influence(2)
    else 
      modify_influence(-2)
    end
  end

  def improving_the_city #Улучшение города
    if success.to_i == 1
      modify_influence(3)
    else 
      modify_influence(-3)
    end
  end

  def sermon #Проповедь
    if success.to_i == 1
      modify_influence(1)
      region = Region.find_by_id(params['region_id'])
      PublicOrderItem.add(10, self.political_action_type.name, region, self) if region
    end  
  end

  def root_out_heresies #Искоренить ереси
    if success.to_i == 1
      modify_influence(2)
    else 
      modify_influence(-2)
      region = Region.find_by_id(params['region_id'])
      PublicOrderItem.add(-5, self.political_action_type.name, region, self) if region
    end
  end
    
  def call_for_unity #Призыв к единству
    if success.to_i == 1
      modify_influence(3)
      countries = Country.where(id: [Country::PERMIAN, Country::VYATKA,Country::RYAZAN, Country::TVER, Country::NOVGOROD])
      countries.each {|c| c.change_relations(1, self)}
    else
      modify_influence(-3)
    end
  end

  def counterintelligence #Контрразведка
    if success.to_i == 1 
      modify_influence(1)
    end
  end

  def fabricate_a_denunciation #Сфабриковать донос
    if success.to_i == 1
      player_2 = Player.find_by_id(params['player_id'])
      modify_influence(2)
      InfluenceItem.add(-2, self.political_action_type.name, player_2, self)
    else 
      modify_influence(-2)
    end
  end

  def favoritism #Фаворитизм
    if success.to_i == 1
      player_2 = Player.find_by_id(params['player_id'])
      modify_influence(3)
      InfluenceItem.add(3, self.political_action_type.name, player_2, self)
    else 
      modify_influence(-3)
    end
  end

  def dev_the_economy #Развитие хозяйства
    if success.to_i == 1
      modify_influence(1)
    end 
  end

  def confused_mine #Спутал свое с государственным
    if success.to_i == 1
      modify_influence(2)
    else 
      modify_influence(-3)
    end
  end

  def patronage_of_infidel #Покровительство иноверцам
    if success.to_i == 1
      modify_influence(3)
      it = Technology.find_by_id(params['technology_id'])
      it&.open_it(Country.current)
    else 
      regions = Country.current.regions
      modify_influence(-3)
      regions.each {|r| PublicOrderItem.add(-3, self.political_action_type.name, r, self)}
    end
  end

  private

    # Действие без явно указанного государства попадает в текущее государство
    def assign_default_country
      return if country_id.present?

      default_country = Country.current || Country.find_by(id: Country::RUS)
      self.country_id = default_country&.id
    end

    def modify_influence value
      InfluenceItem.add(value, self.political_action_type.name, player, self)
    end

    # Державы «Отправить посольство»: две выбранные, без повторов. Один параметр
    # (старый клиент) — одна держава.
    def embassy_countries
      ids = [params['country_id'], params['country_id_2']]
            .map { |value| value.to_i }
            .reject(&:zero?)
            .uniq
      return Country.none if ids.empty?

      Country.where(id: ids)
    end

    # Случайная держава для провала «Взять мзду»: Москва и Новгород исключены
    # (решение заказчика), своё государство тоже — отношений с собой нет.
    def take_bribe_random_country
      excluded = TAKE_BRIBE_EXCLUDED_COUNTRIES + [country_id].compact
      Country.where.not(id: excluded).order(:id).to_a.sample
    end
end
