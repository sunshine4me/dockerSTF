#!/bin/bash

if [ ! -n "$1" ] ;then
	hostname="127.0.0.1"
else
	hostname="$1"
fi
echo "服务IP:${hostname}"


apt update

#安装 docker
echo "检查Docker......"
docker -v
if [ $? -eq  0 ]; then
    echo "检查到Docker已安装!"
else
    echo "安装docker环境..."
    curl -sSL https://get.docker.com/ | sh
    echo "安装docker环境...安装完成!"
fi

echo "拉取必要的image"
docker pull openstf/stf:latest
docker pull sorccu/adb:latest



echo "停止所有容器"
docker stop $(docker ps -a -q)
sleep 1

echo "删除所有容器"
docker rm -v $(docker ps -a -q)
sleep 1

echo "启动adbd"
docker run -d --name adbd --privileged -v /dev/bus/usb:/dev/bus/usb --net host sorccu/adb:latest

echo "启动stf provider"
docker run -d --name provider1 --net host openstf/stf \
stf provider --name provider1 \
--connect-sub tcp://${hostname}:7250 \
--connect-push tcp://${hostname}:7270 \
--min-port=15000 --max-port=25000 --heartbeat-interval 20000 --allow-remote --no-cleanup \
--storage-url http://${hostname}