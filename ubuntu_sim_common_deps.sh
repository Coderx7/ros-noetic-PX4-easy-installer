#!/bin/bash

## Bash script for setting up a PX4 development environment on Ubuntu LTS (16.04 and above).
## It can be used for installing simulators (only) or for installing the preconditions for Snapdragon Flight or Raspberry Pi.
##
## Installs:
## - Common dependencies and tools for all targets (including: Ninja build system, latest versions of cmake, git, anaconda3, pyulog)
## - jMAVSim simulator dependencies
## - PX4/Firmware source (to ~/src/Firmware/)

# Preventing sudo timeout https://serverfault.com/a/833888
trap "exit" INT TERM; trap "kill 0" EXIT; sudo -v || exit $?; sleep 1; while true; do sleep 60; sudo -nv; done 2>/dev/null &

# Ubuntu Config
echo "Remove modemmanager"
sudo apt-get remove modemmanager -y
echo "Add user to dialout group for serial port access (reboot required)"
sudo usermod -a -G dialout $USER

# Update CMake and Git
# Installing latest version of cmake (ref https://askubuntu.com/questions/355565/#865294 )
echo "Installing latest version of CMake"
sudo apt update && \
sudo apt install -y software-properties-common lsb-release && \
sudo apt clean all
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
sudo apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main"
sudo apt update
sudo apt install kitware-archive-keyring
sudo rm /etc/apt/trusted.gpg.d/kitware.gpg
sudo apt update
sudo apt install cmake -y

# Installing latest version of git
echo "Installing latest version of git"
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt-get update
sudo apt-get install git -y

# Install anaconda3
read -p "Do you wish to install anaconda3? [default: No]" yn
    case ${yn:-No} in
        [Yy]* ) { echo >&2 "Installing anaconda3 (python 3.8.8)"; wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh; bash ./Anaconda3-2021.05-Linux-x86_64.sh; eval "$(cat ~/.bashrc | tail -n +10)"; };;
        [Nn]* ) { echo Using system\'s default python;  sudo apt install python3-dev python3-pip -y; };;
        * ) echo "Please answer yes or no.";;
    esac

# Common dependencies
echo "Installing common dependencies"
sudo apt-get update -y
sudo apt-get install git zip cmake build-essential genromfs ninja-build exiftool astyle -y
# make sure xxd is installed, dedicated xxd package since Ubuntu 18.04 but was squashed into vim-common before
which xxd || sudo apt install xxd -y || sudo apt-get install vim-common --no-install-recommends -y
# Required python packages
#sudo apt-get install python3-argparse python3-empy python3-toml python3-numpy python3-dev python3-pip -y
#sudo -H pip3 install --upgrade pip3
#sudo -H pip install pandas jinja2 pyserial pyyaml
# optional python tools
#sudo -H pip install pyulog
pip3 install argparse empy toml numpy
pip3 install pandas jinja2 pyserial pyyaml
pip3 install pyulog

# jMAVSim simulator dependencies
echo "Installing jMAVSim simulator dependencies"
sudo apt-get install ant openjdk-8-jdk openjdk-8-jre -y

