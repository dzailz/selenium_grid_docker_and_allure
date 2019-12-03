#!/bin/bash

source ~/stepik_traineeship/env/bin/activate
cd ~/stepik_traineeship/edy-tests/Webdriver/scripts/
echo "Starting scripts"
gnome-terminal -x sh -c "py.test --alluredir=/home/dzailz/stepik_traineeship/allure/ -v -s -m smoke --executor=http://127.0.0.1:4444/wd/hub --domain=https://staging1.int.stepik.org -n2 --browser=chrome ; bash"
sleep 2
py.test --alluredir=/home/dzailz/stepik_traineeship/allure/ -v -s -m smoke --executor=http://127.0.0.1:4444/wd/hub --domain=https://staging1.int.stepik.org --browser=firefox -n2
