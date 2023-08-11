class SettleService
  attr_accessor :name, :category
  def initialize(name: nil, category: nil)
    @name = name
    @category = category
  end

  def save
    if @name.present? || @category.present?
      f = File.open("db/my_db/settle.csv", "a+")
      f.puts "#{@name};#{@category}"
      f.close
    end
  end
  def self.all
    f = File.open("db/my_db/settle.csv", "r")
    f.read
  end
end