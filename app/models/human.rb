class Human < ApplicationRecord
  audited

	has_many :players
end
