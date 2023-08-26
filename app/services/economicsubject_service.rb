class EconomicsubjectService
  attr_accessor :name, :category, :money
  def self.all
    f = File.open("db/my_db/economicsubject.csv", "r")
    str = f.gets.strip
    economicsubjects = []
    while (str.present?)
      economicsubject = EconomicsubjectService.new
      economicsubject.name = str.split(";")[0]
      economicsubject.category = str.split(";")[1]
      economicsubject.money = str.split(";")[2]
      economicsubjects.push(economicsubject)
      str = f.gets
    end
    f.close
    economicsubjects
  end
end
