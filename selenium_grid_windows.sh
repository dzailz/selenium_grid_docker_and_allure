#!/bin/bash

source ~/stepik_traineeship/env/bin/activate
cd ~/stepik_traineeship/edy-tests/Webdriver/scripts/
echo "Starting scripts"
gnome-terminal -x sh -c "py.test -v -s -m smoke --executor=http://192.168.111.111:4444/wd/hub --platform=windows --domain=https://staging1.int.stepik.org --browser=chrome -n3; bash"
py.test -v -s -m smoke --executor=http://192.168.111.111:4444/wd/hub --platform=windows --domain=https://staging1.int.stepik.org -n3
# the command bellow is not work on win 10 because windows 10 dose not have IE11
# py.test -v -s -m smoke --executor=http://192.168.111.111:4444/wd/hub --platform=windows --domain=https://staging1.int.stepik.org --browser=ie11 -n3

