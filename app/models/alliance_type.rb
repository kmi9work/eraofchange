class AllianceType < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :min_relations_level, presence: true, numericality: { only_integer: true }
end

