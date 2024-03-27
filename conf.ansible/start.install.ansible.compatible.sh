#!/bin/sh
sudo apt-get update
sudo apt-get install software-properties-common
sudo apt-get install python-pip
sudo apt-get install python3-pip
sudo -H pip install ansible==2.8.0.0
