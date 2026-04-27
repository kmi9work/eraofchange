1. Клонируем проект
```bash
git clone git@github.com:kmi9work/first.git
```

2. Переходим в директорию проекта
```bash 
cd first
```

3. Проверяем, что мы находимся в ветке master
```bash
git status
```

4. Если мы не в ветке master - переходим в неё.
```bash
git checkout master
```

5. Скачиваем последние изменения из ветки master в репозитории
```bash
git pull origin master
```

6. Создаем и переходим в ветку для разработки
```bash
git checkout -b issue_30303
```

7. Теперь работаем с ней в обычном режиме:
```bash  
#Изменяем код
git add .
git commit -m 'another feature'

#Снова изменяем код
git add app/view/trololo.html.erb
git commit -m 'hotfix'
```

8. Пушим изменения в удаленную репу
```bash    
git push origin issue_30303
```

8. Пушим изменения в удаленную репу
```bash
git push origin issue_30303
```

9. Если всё правильно - git выведет ссылку на создание pull реквеста
```bash
remote: Create a pull request for '5_homework' on GitHub by visiting:
remote:      https://github.com/kmi9work/first/pull/new/5_homework
```
Переходим по ссылке и создаем pull реквест.
