class SettleService
  attr_accessor :id, :name, :category
  def self.all 
    settle = read_from_file
    #чтение всех элементов из файла
  end

  def self.create(name, category)
    f_max_id = File.open("db/my_db/settle_max_id.csv", "r")
    new_id = f_max_id.gets.to_i + 1
    f_max_id.close

    f_settle = File.open("db/my_db/settle.csv", "a+")
    str = "#{new_id};#{name};#{category}"
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
      read_id = str.split(";")[0]&.to_i
      if read_id == settle_id.to_i
        settle = split_settle(str)
        break
      end
    end
    settle
  end

  def update(new_name, new_category)
    settles = SettleService.read_from_file
    #чтение всех элементов из файла

    settle = settles.find{|s| s.id.to_i == @id}
    settle.name = new_name
    settle.category = new_category

    SettleService.write_to_file(settles)
    #запись всех элементов в файл
  end

  def destroy
    settles = SettleService.read_from_file
    settle = settles.delete_if{|s| s.id.to_i == @id}
    settles = SettleService.write_to_file(settles)
  end
  
  def self.split_settle(str)
    settle = SettleService.new
    settle.id = str.split(";")[0].to_i
    settle.name = str.split(";")[1]
    settle.category = str.split(";")[2]
    settle
  end

  def self.read_from_file
    f = File.open("db/my_db/settle.csv", "r")
    settles = []
    f.each do |str|
      settle = SettleService.split_settle(str)
      settles.push(settle)
    end
    f.close
    settles
  end

  def self.write_to_file(settles)
    f = File.open("db/my_db/settle.csv", "w")
    settles.each do |settle|
      str = "#{settle.id};#{settle.name};#{settle.category}"
      f.puts str
    end
    f.close
  end

end
