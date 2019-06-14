#!/bin/bash

echo "apt update......"
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


#启动 docker
service docker start

#拉取必要的image
docker pull openstf/stf:latest
docker pull rethinkdb:2.3
docker pull nginx:1.7.10

#创建必要的文件夹
mkdir rethinkdb_data
mkdir storage
chmod 777 storage

#获取当前目录
workdir=$(cd $(dirname $0); pwd)

read -p "输入服务使用的IP或域名:" hostname

echo "停止所有容器"
docker stop $(docker ps -a -q)
sleep 1

echo "删除所有容器"
docker rm -v $(docker ps -a -q)
sleep 1

echo "启动nginx"
docker run -d  --name nginx -v "${workdir}/nginx.conf:/etc/nginx/nginx.conf:ro" --net host nginx:1.7.10 nginx


echo "启动 rethinkdb"
docker run -d --name some-rethink -v "${workdir}/rethinkdb_data:/data" --net host rethinkdb:2.3 rethinkdb --cache-size 2048 --no-update-check
sleep 3


# 初始化数据表,只需要执行一次
echo "rethinkdb init"
docker run --rm --name stf-migrate --net host openstf/stf:latest stf migrate
sleep 3

echo "启动 stf app"
docker run -d --name stf-app --net host -e "SECRET=YOUR_SESSION_SECRET_HERE" openstf/stf:latest stf app --port 7100 --auth-url http://${hostname}/auth/mock/ --websocket-url ws://${hostname}/
sleep 3

echo "启动 stf auth-mock"
docker run -d --name stf-auth --net host -e "SECRET=YOUR_SESSION_SECRET_HERE" openstf/stf:latest stf auth-mock --port 7101 --app-url http://${hostname}/
sleep 1

echo "启动 stf websocket"
docker run -d --name websocket --net host -e "SECRET=YOUR_SESSION_SECRET_HERE" openstf/stf:latest stf websocket --port 7102 --storage-url http://${hostname}/ --connect-sub tcp://${hostname}:7150 --connect-push tcp://${hostname}:7170
sleep 1

echo "启动 stf api"
docker run -d --name stf-api --net host -e "SECRET=YOUR_SESSION_SECRET_HERE" openstf/stf:latest stf api --port 7103 --connect-sub tcp://${hostname}:7150 --connect-push tcp://${hostname}:7170
sleep 1

echo "启动 stf storage-plugin-apk"
docker run -d --name storage-apk --net host openstf/stf:latest stf storage-plugin-apk --port 7104 --storage-url http://${hostname}/
sleep 1

echo "启动 stf storage-plugin-image"
docker run -d --name storage-image --net host openstf/stf:latest stf storage-plugin-image --port 7105 --storage-url http://${hostname}/
sleep 1

echo "启动 stf storage-temp"
docker run -d --name storage-temp --net host -v "${workdir}/storage:/data" openstf/stf:latest stf storage-temp --port 7106 --save-dir /data
sleep 1

echo "启动 stf triproxy app"
docker run -d --name triproxy-app --net host openstf/stf:latest stf triproxy app --bind-pub "tcp://*:7150" --bind-dealer "tcp://*:7160" --bind-pull "tcp://*:7170"
sleep 1

echo "启动 stf processor"
docker run -d --name stf-processer --net host openstf/stf:latest stf processor stf-processer --connect-app-dealer tcp://127.0.0.1:7160 --connect-dev-dealer tcp://127.0.0.1:7260
sleep 1

echo "启动 stf triproxy dev"
docker run -d --name triproxy-dev --net host openstf/stf:latest stf triproxy dev --bind-pub "tcp://*:7250" --bind-dealer "tcp://*:7260" --bind-pull "tcp://*:7270"
sleep 1

echo "启动 stf reaper dev"
docker run -d --name stf-reaper --net host openstf/stf:latest stf reaper dev --connect-push tcp://127.0.0.1:7270 --connect-sub tcp://127.0.0.1:7150 --heartbeat-timeout 30000
