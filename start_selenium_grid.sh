#!/bin/bash

cd ~/sprint_4_SeleniumGrid
echo "Starting HUB"
java -jar selenium-server-standalone.jar -role hub -hubConfig hubConfig.json &
export hub=$!
echo $hub
echo "Starting NODes"
java -jar selenium-server-standalone.jar -role node -nodeConfig firefoxNodeConfig.json &
export node0=$!
echo $node0
java -jar selenium-server-standalone.jar -role node -nodeConfig chromeNodeConfig.json &
export node1=$!
echo $node1
source ~/stepik_traineeship/env/bin/activate
cd ~/stepik_traineeship/edy-tests/Webdriver/scripts/
echo "Starting scripts"
gnome-terminal -x sh -c "py.test -v -s -m smoke --executor=http://localhost:3333/wd/hub --domain=https://staging1.int.stepik.org --browser=chrome; bash"
py.test -v -s -m smoke --executor=http://localhost:3333/wd/hub --domain=https://staging1.int.stepik.org --browser=chrome
sleep 5
kill $hub
kill $node0
kill $node1


