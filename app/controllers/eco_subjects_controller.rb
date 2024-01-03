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


 
def aad(s)
 s = 1
 d = 0
 a = 2 
 n = 22
  while(d<n)
    d+=1
    s=s*a
  end 
   puts s
end   

d = 0
  n = 3
  while(d<n)
   d+=1
   puts "--"
  end 



def sum
  d = [ ]
  arr = [1,2,3]
  var = [1,2,3]
  var.each do |i,a|
   d = i+1
   puts d
 end
end


 def sum
  arr = [1,2,3,4]
  s = 0
  arr.each do |i|
    s=s+i
  end 
  puts s 
 end 

 def sum
  arr = [1,2,3,4]
  s = 0
  for i in  arr do 
    s=s+i
  end 
  puts s 
 end 

def sum
  arr = [1,2,3]
  var = [1,2,3]
  d = [ ]
  a = 0
  b = 0
  arr.each do |i|
    a = i
   end 
   var.each do |i|
    b = i
  end
  d = arr[a]
  puts d
end