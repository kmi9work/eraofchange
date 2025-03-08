class InfluenceItem < ApplicationRecord
  audited

  belongs_to :player
  belongs_to :entity, polymorphic: true, optional: true

  def self.add value, comment, player, entity = nil
    InfluenceItem.create(
      value: value, 
      comment: comment,
      year: GameParameter.current_year,
      player: player,
      entity: entity
    )
  end
end
