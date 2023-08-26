class EconomicsubjectService
  attr_accessor :name, :category, :property
  def self.all
    f = File.open("db/my_db/economicsubject.csv", "r")
    str = f.gets
    
    economicsubjects = []

    while (str.present?)
      economicsubject = EconomicsubjectService.new
      economicsubject.name =  str.split(";")[0]
      economicsubject.category = str.split(";")[1]
      economicsubject.property = str.split(";")[2]
        
        #if str.split(";")[1] == "town\n"
        economicsubjects.push(economicsubject)
        #end

      str = f.gets
    end
    f.close
    

    economicsubjects
    
  end

end








