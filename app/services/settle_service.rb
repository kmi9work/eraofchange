class SettleService
  attr_accessor :name, :category
  def self.all 
    f = File.open("db/my_db/settle.csv", "r")
    str = f.gets.strip
    settles = []
    while (str.present?)
      
      settle = SettleService.new
      settle.name = str.split(";")[0]
      settle.category = str.split(";")[1]
       if settle.category =="town"
          settles.push(settle)
       end
      
      str = f.gets
      
    end
    
    f.close
    settles
 end
end
