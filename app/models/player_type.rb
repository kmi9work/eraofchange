class PlayerType < ApplicationRecord
  belongs_to :ideologist_type, optional: true
end