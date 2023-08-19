class SettleService
  attr_accessor :name, :category
  def self.all
    f = File.open("db/my_db/settle.csv", "r")
    #Открываем файл на чтение
    str = f.gets.strip
    #Читаем первую строку из файла в переменную str
    settles = []
    while (str.present?)
      #Проверяем, есть ли в str что-то.
      settle = SettleService.new
      #Создаём новый экземпляр класса
      settle.name = str.split(";")[0]
      #разделяем прочитанную строку по ";" в массив.
      #Берем первое значение из этого массива и кладём его в переменную экземпляра класса name.
      settle.category = str.split(";")[1]
      #Берем второе значение из этого массива и кладём его в переменную экземпляра класса category.
      settles.push(settle)
      #Кладём наш экземпляр в конец массива settles.
      str = f.gets.strip
      #Читаем следующую строку из файла в переменную str
    end
    f.close
    #Закрываем файл
    settles
    #Возвращаем результат settles
  end
end
