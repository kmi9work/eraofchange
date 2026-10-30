# Итог сражения из клиента мастеров (era_native).
#
# Бой на экране «Сражения» считается НА КЛИЕНТЕ: `Army#attack` (веб-админка)
# там не вызывается, поэтому сервер узнаёт итог только этим запросом. Отсюда
# мастерам сражений и политики уходит полноэкранное уведомление — то же, что
# приходит по бою 1×1 из веб-админки.
class BattlesController < ApplicationController
  # POST /battles/report.json
  #   { attackers: [{"label": "Армия (Иван)"}], defenders: [...],
  #     winner_side: "attacker"|"defender", outcome: "defenders_destroyed",
  #     place: "Тверь", round: 3, fallen_troops: 2, winner_country_id: 1 }
  #
  # Клиент отправляет тело двумя формами (обёрнутое в `request` и плоское) —
  # принимаем обе: era_front и era_native шлют по-разному.
  def report
    data = params_data
    created = NotificationRule.battle_reported(
      attackers: data['attackers'],
      defenders: data['defenders'],
      winner_side: data['winner_side'],
      outcome: data['outcome'],
      place: data['place'],
      round: data['round'],
      fallen_troops: data['fallen_troops'],
      winner_country: Country.find_by(id: data['winner_country_id'].to_i)
    )

    render json: { success: true, notified: created.size }
  end

  private

  def params_data
    raw = params[:request].present? ? params[:request] : params
    raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h
  end
end
