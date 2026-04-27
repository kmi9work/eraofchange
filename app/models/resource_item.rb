class ResourceItem < ApplicationRecord
  belongs_to :economic_subject, polymorphic: true, optional: true
end
