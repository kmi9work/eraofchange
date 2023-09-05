class EconomicsubjectService
  attr_accessor :id, :name, :category, :money
  def self.all
    f = File.open("db/my_db/economicsubject.csv", "r")
    str = f.gets.strip
    economicsubjects = []
    while (str.present?)
      economicsubject = EconomicsubjectService.new
      economicsubject.id = str.split(";")[0]
      economicsubject.name = str.split(";")[1]
      economicsubject.category = str.split(";")[2]
      economicsubject.money = str.split(";")[3]
      economicsubjects.push(economicsubject)
      str = f.gets
    end
    f.close
    economicsubjects
  end
end

def self.create(id, name, category, money)
    lines = File.foreach("db/my_db/economicsubject.csv").count
    f = File.open("db/my_db/economicsubject_max_id.csv", "w")
    f.puts lines.to_i + 1
    f.close 
        f = File.open("db/my_db/economicsubject_max_id.csv", "r")
    max_id = f.gets.to_i
    f = File.open("db/my_db/economicsubject.csv", "a+")
    str = "#{max_id}; #{name}; #{category}; #{money}"
    f.puts str
    f.close
    
    end
