class TechnologyItem < ApplicationRecord
  audited

  belongs_to :technology
  belongs_to :entity, polymorphic: true, optional: true
  belongs_to :country, optional: true

  # По одной строке на пару «технология × государство»
  validates :technology_id, uniqueness: { scope: :country_id }, allow_nil: true

  # Открытие технологии (переход 0 → 1) — событие для мастеров сражений:
  # они получают полноэкранное уведомление в клиентах. Закрытие (1 → 0) молчит,
  # создание строки тоже: сиды не должны поднимать окна при старте игры.
  after_save :notify_technology_opened

  def notify_technology_opened
    return unless saved_change_to_value?

    old_value, new_value = saved_change_to_value
    return unless new_value.to_i == 1 && old_value.to_i.zero?

    NotificationRule.technology_opened(self)
  end


  def self.add value, comment, technology, entity = nil, country = Country.current
    TechnologyItem.create(
      value: value, 
      comment: comment,
      year: GameParameter.current_year,
      technology: technology,
      entity: entity,
      # Принимаем и объект государства, и его id (старый код передавал Country::RUS)
      country: Country.resolve(country)
    )
  end
end
