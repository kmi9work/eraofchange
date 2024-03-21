class PoliticalActionType < ApplicationRecord
	belongs_to :political_action, optional: true
end
