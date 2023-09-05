class SettleService
  attr_accessor  :id, :name, :category
  def self.all 
    f = File.open("db/my_db/settle.csv", "r")
    str = f.gets.strip
    settles = []
    while (str.present?)
      
      settle = SettleService.new
      settle.id = str.split(";")[0]
      settle.name = str.split(";")[1]
      settle.category = str.split(";")[2]
      settles.push(settle)
      
      
      str = f.gets
      
    end
    
    f.close
    settles
 end

  def self.create(name, category)
    #с помощью костыля
=begin
    f = File.open("db/my_db/settle_max_id.csv", "r")
    max_id = f.gets.to_i
    f = File.open("db/my_db/settle.csv", "a+") #пишет в конец, а также создает новый файл.
    str = "#{max_id+1};#{name}; #{category}" #добавляет переменную внутрь строки
    f.puts str
    f.close
    f = File.open("db/my_db/settle_max_id.csv", "w")
    str = max_id + 1
    f.puts str
    f.close
=end
    #по-умному
    lines = File.foreach("db/my_db/settle.csv").count
    f = File.open("db/my_db/settle_max_id.csv", "w")
    f.puts lines.to_i + 1
    f.close 
    f = File.open("db/my_db/settle_max_id.csv", "r")
    max_id = f.gets.to_i
    f = File.open("db/my_db/settle.csv", "a+")
    str = "#{max_id}; #{name}; #{category}"
    f.puts str
    f.close

  end

  

end
