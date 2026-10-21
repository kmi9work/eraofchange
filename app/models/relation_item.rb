class RelationItem < ApplicationRecord
  audited

  belongs_to :country
  belongs_to :partner_country, class_name: 'Country', optional: true
  belongs_to :entity, polymorphic: true, optional: true

  # Отношения считаются на пару государств: самопара смысла не имеет
  validate :countries_must_differ

  def self.add value, comment, country, entity = nil, partner_country = Country.current
    RelationItem.create(
      value: value, 
      comment: comment,
      year: GameParameter.current_year,
      country: Country.resolve(country),
      entity: entity,
      # Второй конец пары. Старый код передавал сюда целочисленную константу
      # Country::RUS, поэтому значение приводится к объекту государства.
      partner_country: Country.resolve(partner_country)
    )
  end

  private

  def countries_must_differ
    return if country_id.blank? || partner_country_id.blank?
    return if country_id != partner_country_id

    errors.add(:partner_country_id, "не может совпадать со страной (отношения считаются на пару государств)")
  end
end
