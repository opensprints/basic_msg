#!/bin/bash          

# Ubuntu install
if [ -f /etc/lsb-release ]; then
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root (sudo)" 1>&2
    exit 1
  fi

  echo "Downloading and Installing Packages..."
  apt-get update
  apt autoremove --assume-yes
  apt-get install --assume-yes arduino arduino-core wget unzip curl python screen
  # Fix any package dependencies
  apt-get -f install
  apt-get install --assume-yes arduino arduino-core wget unzip curl python screen
 
  echo "Download PlatformIO CLI..."
  rm get-platformio.py
  wget https://raw.githubusercontent.com/platformio/platformio/master/scripts/get-platformio.py
  wget https://raw.githubusercontent.com/platformio/platformio/develop/scripts/99-platformio-udev.rules
  cp ./99-platformio-udev.rules /etc/udev/rules.d/99-platformio-udev.rules
  mv ./99-platformio-udev.rules /lib/udev/rules.d/99-platformio-udev.rules
  
  echo "Install PlatformIO CLI..."
  python ./get-platformio.py
  service udev restart
  rm get-platformio.py
  
  echo "Download OpenSprints (basic_msg) Firmware..."
  rm -rf ./basic_msg* 
  wget https://github.com/opensprints/basic_msg/releases/download/basic-1/basic_msg.zip
  unzip ./basic_msg.zip
  rm ./basic_msg.zip 

  echo "Install OpenSprints (basic_msg) Firmware..."
  cd ./basic_msg
  platformio update
  platformio upgrade
  platformio init --board uno
  mv ./basic_msg.ino ./src
  platformio run --target upload
  platformio run --target clean

  clear
  echo "Hit 'v' then 'g' once the screen goes blank. To stop the test Ctrl+a+\  Hit [ENTER] to begin test."
  read
  screen $(ls /dev/ttyACM*) 115200
fi
