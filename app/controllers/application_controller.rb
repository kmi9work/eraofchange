class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  helper_method :current_user, :current_player, :player_signed_in?, :current_country
  before_action :set_csrf_cookie
  before_action :set_current_player
  before_action :set_current_country
  
  include PlayerAuthentication


  private

  def current_user
    @current_user ||= if session[:user_id]
                        User.find(session[:user_id])
                      else
                        User.find_by(name: 'Аноним') || User.create(name: 'Аноним', job: 'Система')
                      end
  end

  def login(user)
    session[:user_id] = user.id
  end

  def set_csrf_cookie
    cookies["CSRF-TOKEN"] = form_authenticity_token
  end
  
  def set_current_player
    if session[:player_id]
      player = Player.find_by(id: session[:player_id])
      Player.current = player if player
    else
      Player.current = nil
    end
  end

  # Текущее государство — то, за которое сейчас работают мастера. Хранится в сессии,
  # по образцу выбора мастера (session[:user_id]). Правило разрешения:
  # session[:country_id] → «Русь» → первое государство по id (Country.current).
  def set_current_country
    country = session[:country_id].present? ? Country.find_by(id: session[:country_id]) : nil
    Country.current = country
  end

  def current_country
    Country.current
  end
end

