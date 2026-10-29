# Уведомление мастеру: полноэкранное окно в клиентах (era_front / era_native),
# которое закрывается ТОЛЬКО кнопкой «Ок» (acknowledged_at).
#
# Хранится на получателя: одному и тому же человеку может быть адресовано одно
# событие, и подтверждение с любого его устройства снимает окно на остальных.
class Notification < ApplicationRecord
  TECHNOLOGY_OPENED = 'technology_opened'.freeze
  KINDS = [TECHNOLOGY_OPENED].freeze

  belongs_to :user
  belongs_to :technology, optional: true
  belongs_to :country, optional: true

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :title, presence: true

  scope :pending, -> { where(acknowledged_at: nil).order(:created_at, :id) }
  scope :acknowledged, -> { where.not(acknowledged_at: nil) }

  def acknowledged?
    acknowledged_at.present?
  end

  # Идемпотентно: повторное подтверждение не меняет время первого.
  def acknowledge!
    return self if acknowledged?

    update!(acknowledged_at: Time.current)
  end

  # Создать по строке на каждого получателя. Одинаковые пользователи в списке
  # не дублируются: один человек = одно окно.
  def self.deliver(kind:, title:, users:, body: nil, technology: nil, country: nil, payload: {})
    recipients = Array(users).compact.uniq(&:id)

    recipients.map do |user|
      create!(
        kind: kind,
        title: title,
        body: body,
        user: user,
        technology: technology,
        country: country,
        payload: payload
      )
    end
  end

  def self.pending_for(user)
    return none if user.nil?

    user.notifications.pending
  end
end
