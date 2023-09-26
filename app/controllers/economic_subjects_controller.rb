class EconomicSubjectsController < ApplicationController
  
  def index
    @economic_subjects = EconomicSubject.all
  end

  def show
    @economic_subject = EconomicSubject.find_by_id(params[:id])
  end

  def new
    @economic_subject = EconomicSubject.new
  end

  def create
    EconomicSubject.create(name: params[:name], category: params[:category], money: params[:money])
    redirect_to('/economic_subjects')
  end

  def edit
    @economic_subject = EconomicSubject.find_by_id(params[:id])
  end

  def update
    @economic_subject = EconomicSubject.find_by_id(params[:id])
    @economic_subject.update(name: params[:name], category: params[:category], money: params[:money])
    redirect_to(economic_subject_path(@economic_subject))
  end

  def destroy
    @economic_subject = EconomicSubject.find_by_id(params[:id])
    @economic_subject.destroy
    redirect_to(economic_subjects_path)
  end
end
