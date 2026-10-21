# Параметры игры. Для «текущего года» дополнительно отдаём состояние оплаты
# госрасходов: флаг больше не один на игру, а у каждого государства свой (Д12).
# Прежний ключ params.state_expenses сохраняется для совместимости со старым фронтом.
json.extract! game_parameter, :id, :name, :value, :identificator, :created_at, :updated_at

if game_parameter.identificator == "current_year"
  country = current_country || Country.current
  year = GameParameter.current_year
  json.params do
    json.merge! (game_parameter.params || {})
    json.state_expenses country&.state_expenses_paid?(year)
    json.state_expenses_by_country Country.order(:id).map { |c|
      [c.id.to_s, c.state_expenses_paid?(year)]
    }.to_h
  end
  json.country_id country&.id
  json.country country && { id: country.id, name: country.name, short_name: country.short_name }
  json.year year
else
  json.params game_parameter.params
end

json.url game_parameter_url(game_parameter, format: :json)
