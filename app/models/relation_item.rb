class RelationItem < ApplicationRecord
  belongs_to :country
  belongs_to :entity, polymorphic: true, optional: true

  def self.add value, comment, country, entity = nil
    RelationItem.create(
      value: value, 
      comment: comment,
      year: GameParameter.current_year,
      country: country,
      entity: entity
    )
  end
end
