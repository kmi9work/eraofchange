class PoliticalActionType < ApplicationRecord
  SEDITION_PO = 5
  CHARITY_PO = 5

  belongs_to :job
  has_many :political_actions, dependent: :destroy

  
end
