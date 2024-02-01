class PoliticalAction < ApplicationRecord
  belongs_to :political_action_type
  belongs_to :player
end
