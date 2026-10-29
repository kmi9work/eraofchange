class User < ApplicationRecord
  has_many :viewed_audits, dependent: :destroy
  has_many :notifications, dependent: :destroy
end
