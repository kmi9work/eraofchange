class Guild < ApplicationRecord
  audited
  
  belongs_to :country, optional: true

  # Государство гильдии — как у игрока (Д2/Д11): если не задано явно, гильдия
  # относится к текущему государству. При игре за одну страну поведение прежнее,
  # а при нескольких — гильдия сразу принадлежит тому, кто её создал.
  before_validation :assign_default_country, if: -> { country_id.blank? }

  has_many :players
  has_many :caravans
  has_many :plants, :as => :economic_subject,
                    :inverse_of => :economic_subject
  has_many :resource_items, :as => :economic_subject,
                             :inverse_of => :economic_subject
  #validates :name, presence: true { message: "Поле Имя должно быть заполнено" }

  def self.total_count
    count
  end

  def has_contraband_card?(year)
    params&.dig("contraband_years")&.include?(year)
  end

  def grant_contraband_card(year)
    existing_years = params&.dig("contraband_years") || []
    updated_params = (params || {}).merge("contraband_years" => (existing_years | [year]))
    update_column(:params, updated_params)
  end

  private

  def assign_default_country
    self.country_id = Country.current&.id
  end
end

