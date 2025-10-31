class Alliance < ApplicationRecord
  belongs_to :country
  belongs_to :partner_country, class_name: 'Country'
  belongs_to :alliance_type

  validates :country_id, uniqueness: { scope: [:partner_country_id, :alliance_type_id], 
                                        message: "Уже существует союз этого типа с этой страной" }
end

