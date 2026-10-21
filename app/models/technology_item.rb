class TechnologyItem < ApplicationRecord
  audited

  belongs_to :technology
  belongs_to :entity, polymorphic: true, optional: true
  belongs_to :country, optional: true

  # По одной строке на пару «технология × государство»
  validates :technology_id, uniqueness: { scope: :country_id }, allow_nil: true

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
