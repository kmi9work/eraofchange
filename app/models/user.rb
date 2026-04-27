class User < ApplicationRecord
  has_many :viewed_audits, dependent: :destroy
end
