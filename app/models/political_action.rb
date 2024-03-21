class PoliticalAction < ApplicationRecord
    belongs_to :player, optional: true

    has_many :political_action_types

end
