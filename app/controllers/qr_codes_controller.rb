class QrCodesController < ApplicationController
  def index
    @players = Player.all.order(:id)
  end
end
