class Player < ApplicationRecord
  belongs_to :family, optional: true
  belongs_to :merchant, optional: true
end
