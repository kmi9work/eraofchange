class Player < ApplicationRecord
  belongs_to :merchant, optional: true
end
