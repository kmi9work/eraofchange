json.extract! notification, :id, :kind, :title, :body, :technology_id, :country_id,
              :payload, :acknowledged_at, :created_at
# Государство — акцент окна: клиенты рисуют герб (flag_image_name) и название.
json.country notification.country && {
  id: notification.country.id,
  name: notification.country.name,
  short_name: notification.country.short_name,
  flag_image_name: notification.country.flag_image_name
}
json.technology notification.technology && { id: notification.technology.id, name: notification.technology.name }
