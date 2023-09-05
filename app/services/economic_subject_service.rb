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
    f_max_id = File.open("db/my_db/economic_subject_max_id.csv", "r")
    new_id = f_max_id.gets.to_i + 1
    f_max_id.close

    f_es = File.open("db/my_db/economic_subject.csv", "a+")
    str = "#{new_id}; #{name}; #{category}; #{money}"
    f_es.puts str
    f_es.close

    f_max_id = File.open("db/my_db/economic_subject_max_id.csv", "w")
    f_max_id.puts new_id
    f_max_id.close
  end

  def self.count(id)
    f = File.open("db/my_db/economicsubject.csv", "r")
    str = f.gets.strip
    number_of_ids = 0

    while (str.present?)
      number_of_ids =+1 
    end
    
    number_of_ids
  end

end