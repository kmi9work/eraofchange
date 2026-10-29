json.extract! notification, :id, :kind, :title, :body, :technology_id, :country_id,
              :payload, :acknowledged_at, :created_at
json.country notification.country && { id: notification.country.id, name: notification.country.name }
json.technology notification.technology && { id: notification.technology.id, name: notification.technology.name }
