class TechnologyItem < ApplicationRecord
  audited

  belongs_to :technology
  belongs_to :entity, polymorphic: true, optional: true

  def self.add value, comment, technology, entity = nil
    TechnologyItem.create(
      value: value, 
      comment: comment,
      year: GameParameter.current_year,
      technology: technology,
      entity: entity
    )
  end
end
