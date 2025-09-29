# frozen_string_literal: true

# Конфигурация для audited gem
Audited.config do |config|
  config.audit_class = "CustomAudit"
end
