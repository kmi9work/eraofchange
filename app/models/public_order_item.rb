class PublicOrderItem < ApplicationRecord
  audited

  belongs_to :region
  belongs_to :entity, polymorphic: true, optional: true

  def self.add value, comment, region, entity = nil
    if region.present?
      PublicOrderItem.create(
        value: value, 
        comment: comment,
        year: GameParameter.current_year,
        region: region,
        entity: entity
      )
    else
      Country.find(Country::RUS).regions.each do |region|
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
