# README

## Работа с файлом
```ruby
f = File.open("db/my_db/settle.csv", "r") # Открытие
str = f.gets.strip # Чтение из файла
f.close # Закрыть файл
```