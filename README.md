# v2rayDocker = v2ray + caddy2 + ws + tls + qrcode

* 自动生成 uuid 和 ws path
* 默认使用 caddy2 自动生成证书
* 自动生成 安卓 v2rayNG vmess 链接和二维码
* 自动生成 iOS shadowrocket vmess 链接和二维码
* 已屏蔽非相关文件的访问

## 组件版本

* v2ray：v4.34.0
* Caddy：v2.3.0
* alpine：latest

## 使用方法

* 提前准备
  #####  1. 给域名（如 YOURDOMAIN.COM）添加 A 记录，确保正确解析到 Docker 所在服务器。具体设置方法可参看：https://help.aliyun.com/knowledge_detail/29725.html
  #####  2. 确认运行环境 80 和 443 端口未被占用。可运行 lsof -i:80 和 lsof -i:443 检查。
* 安装 Docker 
```
curl -fsSL https://get.docker.com -o get-docker.sh  && \
bash get-docker.sh
```
* 启动 Docker
  ##### 1. 务必替换自己的域名（YOURDOMAIN.COM）。
  ##### 2. 可留空（会自动生成）或自行替换 uuid （0890b53a-e3d4-4726-bd2b-52574e8588c4）和 ws path （3o38nn5h）。
```
sudo docker run -d --rm --name v2ray -p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy c258c4fff5f9/v2ray_ws:v0.5.1 YOURDOMAIN.COM V2RAY_WS 0890b53a-e3d4-4726-bd2b-52574e8588c4 3o38nn5h && sleep 3s && sudo docker logs v2ray
```
* 查看 Docker
```
sudo docker logs v2ray
```
* 停止 Docker
```
sudo docker stop v2ray
```

参考并感谢原作者 https://github.com/pengchujin/v2rayDocker
