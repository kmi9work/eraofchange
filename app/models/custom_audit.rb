# frozen_string_literal: true

class CustomAudit < Audited::Audit
  # Автоматически устанавливаем год при создании аудита
  before_create :set_year

  private

  def set_year
    self.year = GameParameter.current_year if GameParameter.respond_to?(:current_year)
  end
end
