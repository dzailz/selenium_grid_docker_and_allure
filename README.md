# Selenium Grid.
## Запускаем Selenium Grid локально.
***
#### Установка openJDK
Для работы с гридом необходимо установить Java
1. Установка на Ubuntu 19.04:<br>
Запускаем терминал выполняем следующие команды:
```bash
$ sudo apt update
$ sudo apt upgrade
$ sudo apt install openjdk-13-jdk (вы вольны выбрать другую версию продукта)
```
2. Установка для ОС Windows 7/10
    - Переходим по ссылке https://jdk.java.net/13/ (13-версия, вы можете установить другую)
    - Скачиваем архив
    - Скачанный архив распаковываем и размещаем в удобное для вас место
    - Необходимо прописать в PATH путь до файлов с Java
***
#### Подготовка к запуску Selenium GRID
- Переходим по ссылке https://selenium.dev/downloads/
- Качаем "Latest stable version". На момент написания руководства это "3.141.59"
- Скачанный `*.jar` файл размещаем где удобно
***
#### Запускаем Хаб и НОДы локально, передавая параметры через командную строку
1. Стартуем Хаб `java -jar selenium-server-standalone.jar -role hub -host 127.0.0.1.` Хаб будет доступен по адресу http://localhost:4444
2. Стартуем НОДы `java -jar selenium-server-standalone.jar -role node -hub http://localhost:4444`

Каждое действие необходимо выполнять в отдельном окне терминала.
Вы можете запустить столько нод сколько вам нужно или сколько позволит вам производительность вашего компьютера.

НОДа по умолчанию стартует с 5 сессиями для Firefox и Chrome (для ОС Linux).

##### Теперь мы готовы запускать тесты на гриде!
***
#### Запуск тестов на Гриде
Для запуска тестов на гриде необходимо в "pytest" передать параметр `--executor=http://localhost:4444/wd/hub`
строка запуска может иметь следующий вид:<br>
`py.test -v -s -m smoke --executor=http://localhost:4444/wd/hub --platform=windows --domain=https://staging1.int.stepik.org -n3`
***
#### Остановка запущеных НОД и ХАБа
Для остановки запущеных процессов необходимо использовать комбинацию клавиш `CTRL+C`
***
### Добавляем настройки для нод и хаба с помощью ".json".
Дабы не перечислять все возможные необходимые параметры каждый раз когда вам потребуется запуск Selenium GRID, настройки можно передать при помощи файлов "nodeConfig.json" и "hubConfig.json".

**Пример содержания nodeConfig.json**
```json
{
  "capabilities":
  [
    {
      "browserName": "firefox",
      "marionette": true,
      "maxInstances": 2,
      "seleniumProtocol": "WebDriver"
    },
    {
      "browserName": "chrome",
      "maxInstances": 2,
      "seleniumProtocol": "WebDriver"
    }
  ],
  "host": "127.0.0.1",
  "maxSession": 4,
  "port": -1,
  "register": true,
  "registerCycle": 5000,
  "hub": "http://localhost:4444",
  "nodeStatusCheckTimeout": 5000,
  "nodePolling": 5000,
  "role": "node",
  "unregisterIfStillDownAfter": 60000,
  "downPollingLimit": 2,
  "debug": false,
  "servlets" : [],
  "withoutServlets": [],
  "custom": {}
}
```
**Пример hubConfig.json**
```json
{
  "port": 4444,
  "newSessionWaitTimeout": -1,
  "servlets" : [],
  "withoutServlets": [],
  "custom": {},
  "capabilityMatcher": "org.openqa.grid.internal.utils.DefaultCapabilityMatcher",
  "registry": "org.openqa.grid.internal.DefaultGridRegistry",
  "throwOnCapabilityNotPresent": true,
  "cleanUpCycle": 5000,
  "role": "hub",
  "debug": false,
  "browserTimeout": 0,
  "timeout": 1800
}
```
Теперь для запуска нод и хаба с любыми вашими индивидуальными настройками, достаточно выполнить:
- `java -jar selenium-server-standalone.jar -role node -nodeConfig nodeConfig.json` для нод и;
- `java -jar selenium-server-standalone.jar -role hub -nodeConfig hubConfig.json` для хаба.

Тесты запускаются так-же как и раньше.
***
### Автоматический запуск ХАБА и НОД
Для упрощения процедуры запуска тестов я использую bash скрипт следующего содержания:
```bash
#!/bin/bash

cd ~/sprint_4_SeleniumGrid
gnome-terminal -x sh -c "java -jar selenium-server-standalone.jar -role hub -hubConfig hubConfig.json; bash"
# Я назвал конфигурационные файлы в соответствии с теми браузерами которые они запускают.
gnome-terminal -x sh -c "java -jar selenium-server-standalone.jar -role node -nodeConfig firefoxNodeConfig.json; bash"
gnome-terminal -x sh -c "java -jar selenium-server-standalone.jar -role node -nodeConfig chromeNodeConfig.json; bash"
source ~/stepik_traineeship/env/bin/activate
cd ~/stepik_traineeship/edy-tests/Webdriver/scripts/
gnome-terminal -x sh -c "py.test -v -s -m smoke --executor=http://localhost:4444/wd/hub --domain=https://staging1.int.stepik.org --browser=chrome; bash"
py.test -v -s -m smoke --executor=http://localhost:4444/wd/hub --domain=https://staging1.int.stepik.org
```

Этот скрипт, позволяет запустить вам хаб, ноды и тесты одной командой, все откроются каждый в своей вкладке.
Но поскольку нам всё ещё необходимо будет "гасить" хаб и ноды руками, я предлагаю использовать следующий скрипт:

```bash
#!/bin/bash

cd ~/sprint_4_SeleniumGrid
java -jar selenium-server-standalone.jar -role hub -hubConfig hubConfig.json &
export hub=$!
java -jar selenium-server-standalone.jar -role node -nodeConfig firefoxNodeConfig.json &
export node0=$!
java -jar selenium-server-standalone.jar -role node -nodeConfig chromeNodeConfig.json &
export node1=$!
source ~/stepik_traineeship/env/bin/activate
cd ~/stepik_traineeship/edy-tests/Webdriver/scripts/
gnome-terminal -x sh -c "py.test -v -s -m smoke --executor=http://localhost:4444/wd/hub --domain=https://staging1.int.stepik.org --browser=chrome; bash"
sleep 2
py.test -v -s -m smoke --executor=http://localhost:4444/wd/hub --domain=https://staging1.int.stepik.org
sleep 5
kill $hub
kill $node0
kill $node1
```
Он запускает хаб и ноды в фоновом режиме, а после выполнения последнего теста, выключает их.

### Распределённый запуск хаба и нод
Дабы охватить большее число возможных операционных систем и браузеров, ноды можно запускать на других машинах - как виртуальных так и физических.
Особых тонкостей тут не много.<br>
Желательно передать в хаб и ноды **конкретный** параметр `"host": "YOUR_IP_HERE"` так-как, мною был замечен баг, что хаб раздаёт нодам IP адреса из произвольной подсети, из-за чего и хаб и ноды вроде бы активны, но тесты до них достучаться не могут.
***
## Запуск Selenium Grid в Docker
Docker легко установить по следующей [иснтрукции](https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04).<br>
После установки Docker'а необходимо скачать образ Selenium Grid, и запустить его:
```bash
docker network create grid
```
Теперь мы готовы запускать хаб и ноды. Делается это следующими командами:
```
docker run -d -p 4444:4444 --net grid --name selenium-hub selenium/hub:3.141.59-xenon
docker run -d --net grid -e HUB_HOST=selenium-hub -v /dev/shm:/dev/shm selenium/node-chrome:3.141.59-xenon
docker run -d --net grid -e HUB_HOST=selenium-hub -v /dev/shm:/dev/shm selenium/node-firefox:3.141.59-xenon
```
где `4444:4444` - `порт_локальной_машины:порт_внутри_контейнера`, параметром `HUB_HOST=selenium-hub` мы указываем на имя нашего хаба `--name selenium-hub`, а `-d` - позволяет нам зупустить контейнер в фоновом режиме.

Поскольку, тесты при использовании Грида в Докере работают в headless режиме, я бы рекомендовал запускать их сразу на обе ноды, в несколько потоков. Сделать это можно при помощи скрипта:

```bash
source ~/stepik_traineeship/env/bin/activate
cd ~/stepik_traineeship/edy-tests/Webdriver/scripts/
echo "Starting scripts"
gnome-terminal -x sh -c "py.test -v -s -m smoke --executor=http://127.0.0.1:4444/wd/hub --domain=https://staging1.int.stepik.org -n2; bash"
sleep 2
py.test -v -s -m smoke --executor=http://127.0.0.1:4444/wd/hub --domain=https://staging1.int.stepik.org --browser=chrome -n2
```
По завершении тестов необходимо остановить выполняемые контейнеры и удалить их:
- `docker stop $(docker ps -a -q)` - останавливает все запущенные контейнеры;
- `docker rm $(docker ps -a -q)` - удаляем все остановленые контейнеры.
***
## Docker-compose
Теперь запустим наши тесты использую Docker-Compose:

Для начала установим его:
```bash
sudo apt install docker-compose
```
для запуска хаба и нод, необходимо создать конфигурационный файл `.yml`. Пример такого файла ниже:
```
version: "3"
services:
  selenium-hub:
    image: selenium/hub:3.141.59-xenon
    container_name: selenium-hub
    ports:
      - "4444:4444"
  chrome:
    image: selenium/node-chrome:3.141.59-xenon
    volumes:
      - /dev/shm:/dev/shm
    depends_on:
      - selenium-hub
    environment:
      - HUB_HOST=selenium-hub
      - HUB_PORT=4444
  firefox:
    image: selenium/node-firefox:3.141.59-xenon
    volumes:
      - /dev/shm:/dev/shm
    depends_on:
      - selenium-hub
    environment:
      - HUB_HOST=selenium-hub
      - HUB_PORT=4444
```
запуск происходит так-же очень просто:
```
docker-compose -f grid_hub_nodes_ff_chrome.yml up --scale chrome=2 --scale firefox=2 -d
```
Передав  параметры: `--scale chrome=2 --scale firefox=2`, мы запустим по две ноды для хрома и файерфокса.
Что бы остановить ноды и хаб, необходимо выполнить команду: `docker-compose down`.
***
## Allure-отчеты
Когда тесты запускаются в докер-контейнерах, довольно сложно понять, что пошло не так, когда тесты падают. Поэтому мы добавим отчеты с скриншотами, с помощью которых сможем разбираться с проблемами.<br>
Почему-то установка из официального репозитория не работает (по крайней мере, на момент написания данного руководства), поэтому, я постараюсь объяснить как установить Allure вручную.
1. Для начала перейдём по [ссылке](http://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline/) и скачаем необходимую версию (например [2.13.0](http://repo.maven.apache.org/maven2/io/qameta/allure/allure-commandline/2.13.0/));
2. Распакуем в любую папку, но я бы порекомендовал использовать `~/bin` (её нужно будет создать)
3. Для дальнейшего удобства запуска отчётов, Allure нужно добавить в системную переменную $PATH:
    - Выполняем в терминале команду: `nano ~/.bashrc `;
    - В конец файла добавляем следующие строки: `export PATH="$PATH:/home/USER_NAME/bin/allure/bin"`, где USER_NAME == ваше имя пользователя;
    - Проверить что всё работает, можно командами: `allure --version` и `whereis allure`.

На этом установка завершена.

Для начала работы нам потребуется установить ещё один пакет: "allure-pytest".
Активируем окружение в котором работаем с тестами и вводим команду: `pip install allure-pytest`.

**Приступаем к работе с отчётами**.

Тесты запускаем командой:
```bash
py.test --alluredir=~/stepik_traineeship/allure/ -v -s -m smoke --executor=http://127.0.0.1:4444/wd/hub --domain=https://staging1.int.stepik.org --browser=chrome -n2`
```
где `--alluredir=~/stepik_traineeship/allure/` - папка с хранящимися отчётами по тестам.

Посмотреть как выглядят отчёты можно командой: `allure serve /путь_до_папки_с_отчётами`.
