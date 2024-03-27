class PoliticalAction < ApplicationRecord
  belongs_to :player, optional: true
  belongs_to :political_action_type
end
