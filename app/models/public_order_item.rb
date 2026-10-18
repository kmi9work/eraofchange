class PublicOrderItem < ApplicationRecord
  audited

  belongs_to :region
  belongs_to :entity, polymorphic: true, optional: true

  # region = nil — правка применяется к регионам указанного государства
  # (по умолчанию — текущего: при игре за одну страну это прежнее поведение)
  def self.add value, comment, region = nil, entity = nil, country = Country.current
    if region.present?
      PublicOrderItem.create(
        value: value, 
        comment: comment,
        year: GameParameter.current_year,
        region: region,
        entity: entity
      )
    else
      target_country = country || Country.current
      regions = target_country ? target_country.regions : Region.all
      regions.each do |region|
        PublicOrderItem.create(
          value: value, 
          comment: comment,
          year: GameParameter.current_year,
          region: region,
          entity: entity
        )
      end
    end
  end
end
