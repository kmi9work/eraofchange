class EconomicSubjectService
  attr_accessor :id, :name, :category, :money
  def self.all
    f = File.open("db/my_db/economic_subject.csv", "r")
    str = f.gets.strip
    economic_subjects = []
    while (str.present?)
      economic_subject = EconomicSubjectService.new
      economic_subject.id = str.split(";")[0]
      economic_subject.name = str.split(";")[1]
      economic_subject.category = str.split(";")[2]
      economic_subject.money = str.split(";")[3]
      economic_subjects.push(economic_subject)
      str = f.gets
    end
    f.close
    economic_subjects
  end

  def self.create(name, category, money)
    f = File.open("db/my_db/economic_subject_max_id.csv", "a+")
    max_id = f.gets.to_i
    f.each do
      max_id = max_id + 1
    end
    f.puts (max_id)
    f.close
    f = File.open("db/my_db/economic_subject.csv", "a+")
    str = "#{max_id};#{name};#{category};#{money}"
    f.puts str
    f.close
  end
end