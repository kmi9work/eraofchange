class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  helper_method :current_user 
  before_action :set_csrf_cookie


  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def login(user)
    session[:user_id] = user.id
  end

  def set_csrf_cookie
    cookies["CSRF-TOKEN"] = form_authenticity_token
  end
end
