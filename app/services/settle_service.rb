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
    f = File.open("db/my_db/settle_max_id.csv", "a+")
    max_id = f.gets.to_i
    f.each do
      max_id = max_id + 1
    end
    f.puts (max_id)
    f.close
    f = File.open("db/my_db/settle.csv", "a+")
    str = "#{max_id};#{name};#{category}"
    f.puts str
    f.close
  end

end
