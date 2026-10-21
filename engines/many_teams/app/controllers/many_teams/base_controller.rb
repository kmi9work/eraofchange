module ManyTeams
  # Общая база контроллеров движка: те же before_action, что у ядра
  # (текущее государство из сессии), плюс короткие помощники ответов.
  class BaseController < ::ApplicationController
    private

    def requested_country
      return Country.current if params[:country_id].blank?

      Country.find_by(id: params[:country_id]) || Country.current
    end

    def render_error(message, status = :unprocessable_entity)
      render json: { error: message }, status: status
    end

    def perform_action(action_type_action, params = {}, success: 1)
      type = PoliticalActionType.find_by(action: action_type_action)
      raise ManyTeams::Error, "Действие «#{action_type_action}» не найдено в каталоге" if type.nil?

      player = type.job&.council_players(Country.current)&.first
      if player.nil?
        raise ManyTeams::Error, "Должность «#{type.job&.name}» никем не занята в государстве «#{Country.current&.name}»"
      end

      action = PoliticalAction.new(
        political_action_type: type,
        job: type.job,
        player: player,
        country: Country.current,
        year: GameParameter.current_year,
        success: success,
        params: params || {}
      )
      action.save!
      # Действия движка выполняются сразу (без броска) и возвращают данные
      # отчёта — поэтому вызываем метод напрямую, а не PoliticalAction#execute,
      # который сохраняет запись и теряет возвращённое значение.
      result = action.send(action_type_action)
      [action, result]
    end
  end
end
