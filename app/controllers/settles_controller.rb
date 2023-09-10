class SettlesController < ApplicationController
  def index
    @settles = SettleService.all
  end

  def show
    @settle = SettleService.find_by_id(params[:id])
  end

  def new
    @settle = SettleService.new
  end

  def create
    SettleService.create(params[:name], params[:category])
    redirect_to('/settles')
  end

  def edit
    @settle = SettleService.find_by_id(params[:id])
  end

  def update
    @settle = SettleService.find_by_id(params[:id])
    @settle.update(name: params[:name], category: params[:category])
    redirect_to(settle_path(@settle))
  end

  def destroy
    @settlement = Settlement.find_by_id(params[:id])
    @settlement.destroy
    redirect_to(settlements_path)
  end
end
