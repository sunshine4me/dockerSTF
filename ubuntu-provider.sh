#!/bin/bash

apt update

#安装docker
curl -sSL https://get.docker.com/ | sh

#拉取必要的image
docker pull openstf/stf:latest
docker pull sorccu/adb:latest



# "停止所有容器"
docker stop $(docker ps -a -q)
sleep 1

# "删除所有容器"
docker rm -v $(docker ps -a -q)
sleep 1

# 启动adbd
docker run -d --name adbd --privileged -v /dev/bus/usb:/dev/bus/usb --net host sorccu/adb:latest