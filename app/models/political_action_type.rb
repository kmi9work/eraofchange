class PoliticalActionType < ApplicationRecord
	has_many :political_actions, dependent: :destroy
end
