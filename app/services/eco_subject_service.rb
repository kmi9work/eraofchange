class EcoSubjectService
  attr_accessor :id, :name, :category, :money
  def self.all
    eco_subject = read_from_file
    #чтение всех элементов из файла
  end

  def self.create(name, category, money)
    f_max_id = File.open("db/my_db/eco_subject_max_id.csv", "r")
    new_id = f_max_id.gets.to_i + 1
    f_max_id.close

    f_es = File.open("db/my_db/eco_subject.csv", "a+")
    str = "#{new_id};#{name};#{category};#{money}"
    f_es.puts str
    f_es.close

    f_max_id = File.open("db/my_db/eco_subject_max_id.csv", "w")
    f_max_id.puts new_id
    f_max_id.close
  end

  def self.count
    f = File.open("db/my_db/eco_subject.csv", "r")
    str = f.gets.strip
    number_of_ids = 0

    while (str.present?)
      number_of_ids += 1
      str = f.gets
    end
    number_of_ids
  end

  def self.find_by_id(eco_subject_id)
    f = File.open("db/my_db/eco_subject.csv", "r")
    eco_subject = nil
    f.each do |str|
      read_id = str.split(";")[0]&.to_i
      if read_id == eco_subject_id.to_i
        eco_subject = split_eco_subject(str)
        break
      end
    end
    eco_subject
  end

  def update(new_name, new_category, new_money)
    eco_subjects = EcoSubjectService.read_from_file
    #чтение всех элементов из файла

    eco_subject = eco_subjects.find{|eco_subject| eco_subject.id.to_i == @id}
    eco_subject.name = new_name
    eco_subject.category = new_category
    eco_subject.money = new_money

    EcoSubjectService.write_to_file(eco_subjects)
    #запись всех элементов в файл
  end

  def destroy
    eco_subjects = EcoSubjectService.read_from_file
    eco_subject = eco_subjects.delete_if{|eco_subject| eco_subject.id.to_i == @id}
    eco_subjects = EcoSubjectService.write_to_file(eco_subjects)
  end
  
  def self.split_eco_subject(str)
    eco_subject = EcoSubjectService.new
    eco_subject.id = str.split(";")[0].to_i
    eco_subject.name = str.split(";")[1]
    eco_subject.category = str.split(";")[2]
    eco_subject.money = str.split(";")[3]
    eco_subject
  end

  def self.read_from_file
    f = File.open("db/my_db/eco_subject.csv", "r")
    eco_subjects = []
    f.each do |str|
      eco_subject = EcoSubjectService.split_eco_subject(str)
      eco_subjects.push(eco_subject)
    end
    f.close
    eco_subjects
  end

  def self.write_to_file(eco_subjects)
    f = File.open("db/my_db/eco_subject.csv", "w")
    eco_subjects.each do |eco_subject|
      str = "#{eco_subject.id};#{eco_subject.name};#{eco_subject.category};#{eco_subject.money}"
      f.puts str
    end
    f.close
  end

end
