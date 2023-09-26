class FacilitiesController < ApplicationController

  def index
    @facilities = FacilityService.all
  end

	def show
    @facility = FacilityService.find_by_id(params[:id])
  end

	def new
    @facility = FacilityService.new
  end


	def update
    @facility = FacilityService.find_by_id(params[:id])
    @facility.update(params[:name], params[:category], params[:price], params[:level], params[:location])
    redirect_to(facility_path(@facility.id))
  end


	def create
    FacilityService.create(params[:name], params[:category], params[:price], params[:level], params[:location])
    redirect_to('/facilities')
  end

  def edit
    @facility = FacilityService.find_by_id(params[:id])
  end

  def destroy
    @facility = FacilityService.find_by_id(params[:id])
    @facility.destroy
    redirect_to('/facilities')
  end

end