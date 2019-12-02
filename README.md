# selenium_grid_docker_and_allure

<h1>Selenium Grid
Запускаем Selenium Grid локально </h1>

1. Для запуска Selenium Grid необходимо утановить Java

1.1. Установка для ОС Ubuntu 19.04 <br>
1.1.1 Запускаем терминал выполняем следующие команды:<br>
$ sudo apt update
$ sudo apt upgrade
$ sudo apt install openjdk-13-jdk (вы вольны выбрать другую версию продукта)

1.2. Установка для ОС Windows 7/10
1.2.1. Переходим по ссылке https://jdk.java.net/13/ (13-версия, Вы можете установить другую)
1.2.2. Скачиваем архив
1.2.3. Скачанный архив распаковываем и размещаем в удобное для вас место
1.2.4. Необходимо прописать в PATH путь до файлов с Java

2. Подготовка к запуску Selenium GRID

2.1 Необходимо скачать сам GRID
2.1.1 Переходим по ссылке https://selenium.dev/downloads/
2.1.2 Качаем "Latest stable version". На момент написания руководства это "3.141.59"
2.1.3 Скачанный jar файл размещаем где удобно

Теперь мы готовы к запуску HUB'а и NOD

3. Запускаем Хаб и НОДы локально, передавая параметры через командную строку
3.1. Стартуем Хаб java -jar selenium-server-standalone.jar -role hub -host 127.0.0.1
Хаб будет доступен по адресу http://localhost:4444
3.2. Стартуем НОДы java -jar selenium-server-standalone.jar -role node -hub http://localhost:4444
Вы можете запустить столько нод сколько вам нужно и сколько позволит вам производительность вашего компьютера.
НОДа по умолчанию стартует с 5 сессиями для FireFox и Crome (для ОС Linux)
Теперь мы готовы запускать тесты на гриде!

4. Запуск тестов на гриде
Для запуска тестов на гриде необходимо в pytest передать параметр --executor=http://localhost:4444/wd/hub
строка может иметь следующий вид: py.test -v -s -m smoke --executor=http://localhost:4444/wd/hub --platform=windows --domain=https://staging1.int.stepik.org -n3
