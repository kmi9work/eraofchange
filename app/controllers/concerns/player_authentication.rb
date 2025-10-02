module PlayerAuthentication
  extend ActiveSupport::Concern
  
  private
  
  # Получение текущего игрока из сессии (для обратной совместимости)
  def current_player
    Player.current
  end
  
  # Проверка аутентификации игрока
  def authenticate_player!
    unless Player.current
      render json: { error: 'Требуется аутентификация игрока' }, status: :unauthorized
    end
  end
  
  # Проверка, что игрок аутентифицирован
  def player_signed_in?
    Player.current.present?
  end
end
