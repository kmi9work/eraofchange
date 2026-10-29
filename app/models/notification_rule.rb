# Маршрутизация уведомлений: какое событие каким мастерам показывать.
#
# Должности — свободная строка `users.job` (db/seeds/7_users.rb), поэтому
# сравнение идёт по нормализованной строке, а не по точному равенству.
class NotificationRule
  # Технология (константа Technology::*) → должности мастеров, которым нужно
  # знать об её открытии. Расширять этот список — единственное место правки.
  TECHNOLOGY_RECIPIENT_JOBS = {
    Technology::BLACKSMITHING => ['Сражения'],
    Technology::BALLISTICS => ['Сражения'],
    Technology::CANNING => ['Сражения'],
    Technology::FOREIGN_MERCE => ['Сражения']
  }.freeze

  ANONYMOUS_NAME = 'Аноним'.freeze

  # Латиница, похожая на кириллицу. В сиде должность подмастерья сражений
  # записана латинской «C» («Cражения»), и сравнение строк «как есть» оставило
  # бы половину мастеров сражений без уведомления.
  LOOKALIKES = {
    'A' => 'А', 'B' => 'В', 'C' => 'С', 'E' => 'Е', 'H' => 'Н',
    'K' => 'К', 'M' => 'М', 'O' => 'О', 'P' => 'Р', 'T' => 'Т',
    'X' => 'Х', 'Y' => 'У'
  }.freeze

  class << self
    # Открытие технологии: уведомление получают мастера боевых должностей.
    # Возвращает созданные записи (пустой массив, если технология не в списке).
    def technology_opened(technology_item)
      technology = technology_item&.technology
      return [] if technology.nil?

      jobs = TECHNOLOGY_RECIPIENT_JOBS[technology.id]
      return [] if jobs.blank?

      country = technology_item.country
      body = [country&.name, technology.description].compact_blank.join(' — ').presence

      Notification.deliver(
        kind: Notification::TECHNOLOGY_OPENED,
        title: "Открыта технология «#{technology.name}»",
        body: body,
        users: users_by_jobs(jobs),
        technology: technology,
        country: country,
        payload: {
          'technology_id' => technology.id,
          'country_id' => country&.id,
          'jobs' => jobs
        }
      )
    end

    def users_by_jobs(jobs)
      wanted = Array(jobs).map { |job| fold(job) }
      return [] if wanted.empty?

      User.where.not(name: ANONYMOUS_NAME).select { |user| wanted.include?(fold(user.job)) }
    end

    def fold(value)
      value.to_s.strip.gsub(/[#{LOOKALIKES.keys.join}]/) { |char| LOOKALIKES[char] }.downcase
    end
  end
end
