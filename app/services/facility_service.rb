class FacilityService

attr_accessor :id, :name, :category, :price, :level, :location

  def self.all
    facility = read_from_file
    #чтение всех элементов из файла
  end



 def self.split_facility(str)
    facility = FacilityService.new
    facility.id = str.split(";")[0].to_i
    facility.name = str.split(";")[1]
    facility.category = str.split(";")[2]
    facility.price = str.split(";")[3]
    facility.level = str.split(";")[4]
    facility.location = str.split(";")[5]
    facility
  end

  def self.read_from_file
    f = File.open("db/my_db/facility.csv", "r")
    facilities = []
    f.each do |str|
      facility = FacilityService.split_facility(str)
      facilities.push(facility)
    end
    f.close
    facilities
  end

  def self.find_by_id(facility_id)
    f = File.open("db/my_db/facility.csv", "r")
    facility = nil
    f.each do |str|
      read_id = str.split(";")[0]&.to_i
      if read_id == facility_id.to_i
        facility = split_facility(str)
        break
      end
    end
    facility
  end

	def update(new_name, new_category, new_price, new_level, new_location)
    facilities = FacilityService.read_from_file
    #чтение всех элементов из файла

    facility = facilities.find{|s| s.id.to_i == @id}
    facility.name = new_name
    facility.category = new_category
    facility.price = new_price
		facility.level = new_level	
    facility.location	= new_location	
    FacilityService.write_to_file(facilities)
    #запись всех элементов в файл
  end

  def self.write_to_file(facilities)
    f = File.open("db/my_db/facility.csv", "w")
    facilities.each do |facility|
      str = "#{facility.id};#{facility.name};#{facility.category};#{facility.price};#{facility.level};#{facility.location} "
      f.puts str.strip
    end
    f.close
  end


 def self.create(name, category, price, level, location)
    f_max_id = File.open("db/my_db/facility_max_id.csv", "r")
    new_id = f_max_id.gets.to_i + 1
    f_max_id.close

    f_facility = File.open("db/my_db/facility.csv", "a+")
    str = "#{new_id};#{name};#{category};#{price};#{level};#{location}"
    f_facility.puts str
    f_facility.close

    f_max_id = File.open("db/my_db/facility_max_id.csv", "w")
    f_max_id.puts new_id
    f_max_id.close
  end


	def destroy
    facilities = FacilityService.read_from_file
    facility = facilities.delete_if{|s| s.id.to_i == @id}
    facilities = FacilityService.write_to_file(facilities)
  end


end


