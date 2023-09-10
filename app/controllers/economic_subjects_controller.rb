class EconomicSubjectsController < ApplicationController
  def index
    @economic_subjects = EconomicSubjectService.all
    @count = EconomicSubjectService.count
  end

  def show
    @economic_subject = EconomicSubjectService.find_by_id(params[:id])
    
  end

  def new
    @economic_subject = EconomicSubjectService.new
  end

  def create
    EconomicSubjectService.create(params[:name], params[:category], params[:money])
    redirect_to('/economic_subjects')
  end

  def edit
    
  end

  def update
    
  end

  def destroy
    
  end
end

