class SettleService
  attr_accessor :name, :category
  def self.all
    #Задание 1. Сделать так, чтобы выводились только с категорией "town"
    f = File.open("db/my_db/settle.csv", "r")
    str = f.gets
    settles = []
    while (str.present?)
      settle = SettleService.new
      settle.name = str.split(";")[0]
      settle.category = str.split(";")[1]
      settles.push(settle)
      str = f.gets
    end
    f.close
    settles
  end
end



def name(a, b)
  a + b
end

name(1,2)


# settle = SettleService.new
# settle.find
# SettleService.all

# settle.name = "Kazan"
# puts settle.name