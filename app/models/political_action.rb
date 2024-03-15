class PoliticalAction < ApplicationRecord
  has_many :political_action_types
  belongs_to :player
end
