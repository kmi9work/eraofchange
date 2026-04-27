class ViewedAudit < ApplicationRecord
  belongs_to :user
  validates :audit_id, presence: true, uniqueness: { scope: :user_id }
end
