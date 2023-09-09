class SettleService
  attr_accessor :id, :name, :category
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
    f_max_id = File.open("db/my_db/settle_max_id.csv", "r")
    new_id = f_max_id.gets.to_i + 1
    f_max_id.close

    f_settle = File.open("db/my_db/settle.csv", "a+")
    str = "#{new_id};#{name}; #{category}"
    f_settle.puts str
    f_settle.close

    f_max_id = File.open("db/my_db/settle_max_id.csv", "w")
    f_max_id.puts new_id
    f_max_id.close
  end


  def self.find_by_id(settle_id)
    f = File.open("db/my_db/settle.csv", "r")
    settle = nil    
    f.each do |str|
      read_id = str.split(";")[0]
      
      if read_id == settle_id.to_i
      settle = SettleService.new
      settle.id = read_id
      settle.name = str.split(";")[1]
      settle.category = str.split(";")[2]
      break
    end
  end
  settle
  end





end
