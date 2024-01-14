class EcoSubjectsController < ApplicationController
  
  def index
    @eco_subjects = EcoSubjectService.all
    @count = EcoSubjectService.count
  end

  def show
    @eco_subject = EcoSubjectService.find_by_id(params[:id])
  end

  def new
    @eco_subject = EcoSubjectService.new
  end

  def create
    EcoSubjectService.create(params[:name], params[:category], params[:money])
    redirect_to('/eco_subjects')
  end

  def edit
    @eco_subject = EcoSubjectService.find_by_id(params[:id])
  end

  def update
    @eco_subject = EcoSubjectService.find_by_id(params[:id])
    @eco_subject.update(params[:name], params[:category], params[:money])
    redirect_to(eco_subject_path(@eco_subject.id))
  end

  def destroy
    @eco_subject = EcoSubjectService.find_by_id(params[:id])
    @eco_subject.destroy
    redirect_to('/eco_subjects')
  end
end
