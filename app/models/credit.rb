class Credit < ApplicationRecord
  belongs_to :player, optional: true
end
