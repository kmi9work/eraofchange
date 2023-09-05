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
  f_max_id = File.open("db/my_db/economicsubject_max_id.csv", "r")
  new_id = f_max_id.gets.to_i + 1
  f_max_id.close

  f_es = File.open("db/my_db/economicsubject.csv", "a+")
  str = "#{new_id}; #{name}; #{category}; #{money}"
  f_es.puts str
  f_es.close

  f_max_id = File.open("db/my_db/economicsubject_max_id.csv", "w")
  f_max_id.puts new_id
  f_max_id.close
end
