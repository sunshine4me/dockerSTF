## 一行命令启动stf主服务

将 `127.0.0.1` 替换成服务器IP才能远程访问
```bash
    curl -sSL "https://raw.githubusercontent.com/sunshine4me/dockerSTF/master/ubuntu-app.sh" | sh -s 127.0.0.1
```


## 一行命令启动stf provider
将 `127.0.0.1` 替换成stf主服务的IP
```bash
    curl -sSL "https://raw.githubusercontent.com/sunshine4me/dockerSTF/master/ubuntu-provider.sh" | sh -s 127.0.0.1
```