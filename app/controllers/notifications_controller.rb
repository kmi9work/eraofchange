# Уведомления мастеру: выдача неподтверждённых и подтверждение («Ок»).
#
# Пользователь определяется либо параметром user_id (мобильный клиент, у него
# нет общей сессии с вебом), либо сессией (era_front, где мастер уже выбрал себя
# в шапке). Один и тот же человек может держать окно на нескольких устройствах —
# подтверждение с любого из них снимает его на остальных.
class NotificationsController < ApplicationController
  before_action :set_user

  # GET /notifications.json?user_id=&status=pending|all
  def index
    if @user.nil?
      render json: { error: 'Пользователь не найден' }, status: :not_found
      return
    end

    notifications = @user.notifications.includes(:technology, :country).order(:created_at, :id)
    notifications = notifications.where(acknowledged_at: nil) unless params[:status] == 'all'
    notifications = notifications.where('id > ?', params[:after].to_i) if params[:after].present?

    @notifications = notifications
  end

  # PATCH /notifications/:id/acknowledge.json
  def acknowledge
    notification = @user&.notifications&.find_by(id: params[:id])

    if notification.nil?
      render json: { error: 'Уведомление не найдено' }, status: :not_found
      return
    end

    notification.acknowledge!

    render json: {
      success: true,
      id: notification.id,
      acknowledged_at: notification.acknowledged_at
    }
  end

  private

  def set_user
    @user = if params[:user_id].present?
              User.find_by(id: params[:user_id])
            else
              current_user
            end
  end
end
