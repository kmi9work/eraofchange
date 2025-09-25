# Устанавливаем последний ID аудитов из сидов
last_audit_id = Audited::Audit.maximum(:id) || 0
current_year = GameParameter.find_by(identificator: "current_year")
current_year.params["initial_audit_id"] = last_audit_id
current_year.save

# Отмечаем все аудиты из сидов как прочитанные для всех пользователей
User.all.each do |user|
  Audited::Audit.where('id <= ?', last_audit_id).find_each do |audit|
    ViewedAudit.find_or_create_by(user: user, audit_id: audit.id)
  end
end

puts "Установлен initial_audit_id: #{last_audit_id}"
puts "Отмечено как прочитанные #{last_audit_id} аудитов для #{User.count} пользователей"
