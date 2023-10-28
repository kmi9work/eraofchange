class Merchant < ApplicationRecord
  has_one :player
  belongs_to :family, optional: true
  belongs_to :guild, optional: true
  has_many :plants, :as => :economic_subject,
                    :inverse_of => :economic_subject
end
