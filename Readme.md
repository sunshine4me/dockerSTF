**请在ubuntu系统下使用**

## 一行命令启动stf主服务

将 `127.0.0.1` 替换成服务器IP才能远程访问
```bash
    curl -sSL "https://raw.githubusercontent.com/sunshine4me/dockerSTF/master/ubuntu-app.sh" | sh -s 127.0.0.1
```

启动主服务后直接访问 `http://127.0.0.1`(不需要端口号) 就能看到STF页面


## 一行命令启动stf provider
将 `127.0.0.1` 替换成stf主服务的IP
```bash
    curl -sSL "https://raw.githubusercontent.com/sunshine4me/dockerSTF/master/ubuntu-provider.sh" | sh -s 127.0.0.1
```

启动provider主服务会看到provider 管理的设备