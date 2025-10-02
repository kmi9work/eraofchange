class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  helper_method :current_user, :current_player, :player_signed_in?
  before_action :set_csrf_cookie
  before_action :set_current_player
  
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
end
