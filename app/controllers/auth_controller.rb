class AuthController < ApplicationController
  # CSRF уже отключен в ApplicationController
  
  # Аутентификация по QR-коду
  def login
    identificator = params[:identificator]
    
    if identificator.blank?
      render json: { error: 'Идентификатор не может быть пустым' }, status: :bad_request
      return
    end
    
    player = Player.find_by(identificator: identificator)
    
    if player
      # Устанавливаем сессию
      session[:player_id] = player.id
      session[:player_identificator] = player.identificator
      
      render json: {
        success: true,
        player: {
          id: player.id,
          name: player.name,
          identificator: player.identificator,
          player_type: player.player_type&.name,
          family: player.family&.name,
          jobs: player.jobs.pluck(:name)
        }
      }
    else
      render json: { error: 'Неверный идентификатор' }, status: :unauthorized
    end
  end
  
  # Выход из системы
  def logout
    session[:player_id] = nil
    session[:player_identificator] = nil
    
    render json: { success: true, message: 'Вы успешно вышли из системы' }
  end
  
  # Получение текущего игрока
  def current_player
    if Player.current
      render json: {
        success: true,
        player: {
          id: Player.current.id,
          name: Player.current.name,
          identificator: Player.current.identificator,
          player_type: Player.current.player_type&.name,
          family: Player.current.family&.name,
          jobs: Player.current.jobs.pluck(:name)
        }
      }
    else
      render json: { error: 'Пользователь не аутентифицирован' }, status: :unauthorized
    end
  end
  
  # Генерация QR-кода для игрока (для админки)
  def generate_qr
    player = Player.find(params[:id])
    
    # Создаем QR-код с идентификатором
    qr_data = {
      type: 'player_auth',
      identificator: player.identificator,
      player_name: player.name,
      generated_at: Time.current.iso8601
    }
    
    render json: {
      success: true,
      qr_data: qr_data,
      qr_string: qr_data.to_json
    }
  end
  
  private
  
  # Получение текущего игрока из сессии
  def current_player_session
    return nil unless session[:player_id]
    
    @current_player ||= Player.find_by(id: session[:player_id])
  end
  
  # Проверка аутентификации
  def authenticate_player!
    unless current_player_session
      render json: { error: 'Требуется аутентификация' }, status: :unauthorized
    end
  end
end
