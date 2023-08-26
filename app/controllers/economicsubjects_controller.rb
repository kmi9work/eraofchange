class EconomicsubjectsController < ApplicationController

  def index
    @economicsubjects = EconomicsubjectService.all  
    #@ecosubjects = SettleService.all 
  end
end