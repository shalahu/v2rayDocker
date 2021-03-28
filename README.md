[中文](#功能简介 "中文") | [English](#Features "English")

# v2rayDocker = v2ray + ws + tls + caddy2 + qrcode / xray + tcp + xtls + caddy2 + qrcode

## 功能简介
* 使用共享内存高效进程转发（相比较与端口转发）
* 同时支持 v2ray（ws + tls）和 xray（tcp + xtls），默认 xray 作为 core_type
* 自动生成 user_id、 ws_path 和 user_alertId，也支持自定义
* 与 v2ray 搭配时，默认使用 caddy2 自动生成证书
* 自动生成 安卓 v2rayNG vmess 链接和二维码
* 自动生成 iOS shadowrocket vmess 链接和二维码
* 已屏蔽非相关文件的访问

## 组件版本

* dockerhub: c258c4fff5f9/v2ray_ws:v0.9
* v2ray: v4.36.2
* xray: v1.4.0
* Caddy: v2.3.0
* alpine: v3.13
* golang: v1.16.2

## 使用方法

* 提前准备
  #####  1. 给域名，如 www.yourdomain.com，添加 A 记录，确保正确解析到 Docker 所在服务器的 IP 地址。具体设置方法可参看：https://help.aliyun.com/knowledge_detail/29725.html
  #####  2. 确认运行环境 80 和 443 端口未被占用。可运行 lsof -i:80 和 lsof -i:443 检查。
  #####  3. 当选择 xray（tcp + xtls）是确保 Docker 所在服务器 $HOME/.caddy/acme/acme-v02.api.letsencrypt.org/sites/ws_domain/ws_domain.crt 和 $HOME/.caddy/acme/acme-v02.api.letsencrypt.org/sites/ws_domain/ws_domain.key 两个文件存在（ws_domain 需替换成自己的域名），这个两个文件可通过运行一次 v2ray（ws + tls）从 letsencrypt 自动获取或从其他位置复制。
* 安装 Docker 
  ```
  curl -fsSL https://get.docker.com -o get-docker.sh  && \
  bash get-docker.sh
  ```
* 启动 Docker
  ##### 1. 命令行参数：
  ```
  sudo docker run -d --rm --name v2ray -p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy c258c4fff5f9/v2ray_ws:v0.9 ws_domain(add/host) ws_name(ps) [user_id(id)] [ws_path(path)] [user_alertId(aid)] [core_type(bin)] && sleep 3s && sudo docker logs v2ray
  ```
  ##### 2. 务必将 ws_domain 替换成自己的域名，如 www.yourdomain.com。
  ##### 3. 可留空（将会自动生成）或自行替换 user_id （如 0890b53a-e3d4-4726-bd2b-52574e8588c4）、 ws_path （如 3o38nn5h）和 user_alertId (如 0)。
  ##### 4. 默认 core_type 为 xray，可选 v2ray。
  ##### 5. 完整示例： 
  ```
  sudo docker run -d --rm --name v2ray -p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy c258c4fff5f9/v2ray_ws:v0.9 www.yourdomain.com V2RAY_WS 0890b53a-e3d4-4726-bd2b-52574e8588c4 3o38nn5h 0 xray && sleep 3s && sudo docker logs v2ray
  ```
* 查看 Docker
  ```
  sudo docker logs v2ray
  ```
* 停止 Docker
  ```
  sudo docker stop v2ray
  ```
* 查看链接和二维码（注意：VLESS 并没有正式的链接和二维码标准，使用前仍需手动修改）
  ```
  docker exec -i -t v2ray node link-qrcode.js
  ```  

参考并感谢原作者 https://github.com/pengchujin/v2rayDocker

---

# v2rayDocker = v2ray + ws + tls + caddy2 + qrcode / xray + tcp + xtls + caddy2 + qrcode

## Features

* Use Shared Memory high performance process forwarding (comparing to port forwarding)
* Supporting both v2ray (ws + tls) and xray (tcp + xtls), takes xray as core_type by default 
* Auto generate user_id, ws_path and user_alertId，which also can be customized
* Auto generate CA by caddy2 when working with v2ray
* Auto generate vmess link and QR code for v2rayNG on Android
* Auto generate vmess link and QR code for shadowrocket on iOS
* Block access from nonessential files

## Module Verions

* dockerhub: c258c4fff5f9/v2ray_ws:v0.9
* v2ray: v4.36.2
* xray: v1.4.0
* Caddy: v2.3.0
* alpine: v3.13
* golang: v1.16.2

## How To Run

* Prerequisites
  #####  1. Create an A record for the domain, e.g. www.yourdomain.com, with the IP of docker server.  
  #####  2. port 80 and 443 should be available, check them with lsof -i:80 and lsof -i:443 on the server.
  #####  3. Make sure both $HOME/.caddy/acme/acme-v02.api.letsencrypt.org/sites/ws_domain/ws_domain.crt and $HOME/.caddy/acme/acme-v02.api.letsencrypt.org/sites/ws_domain/ws_domain.key exist on docker server when choose xray (tcp + xtls, replace ws_domain with your domain), could get these 2 files from letsencrypt with running v2ray (ws + tls) once or just copying from other locations.
* Install Docker 
  ```
  curl -fsSL https://get.docker.com -o get-docker.sh  && \
  bash get-docker.sh
  ```
* Start Docker
  ##### 1. Command line arguments:
  ```
  sudo docker run -d --rm --name v2ray -p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy c258c4fff5f9/v2ray_ws:v0.9 ws_domain(add/host) ws_name(ps) [user_id(id)] [ws_path(path)] [user_alertId(aid)] [core_type(bin)] && sleep 3s && sudo docker logs v2ray
  ```
  ##### 2. Must replace ws_domain with your domain, e.g. www.yourdomain.com.
  ##### 3. Keep user_id (e.g. 0890b53a-e3d4-4726-bd2b-52574e8588c4), ws_path (e.g. 3o38nn5h) and user_alertId (e.g. 0) empty (which will be auto-generated) or replace them by your own.
  ##### 4. Takes xray as core_type by default, could repalce it by v2ray.
  ##### 5. Full example:
  ```
  sudo docker run -d --rm --name v2ray -p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy c258c4fff5f9/v2ray_ws:v0.9 www.yourdomain.com V2RAY_WS 0890b53a-e3d4-4726-bd2b-52574e8588c4 3o38nn5h 0 xray && sleep 3s && sudo docker logs v2ray
  ```
* Check Docker
  ```
  sudo docker logs v2ray
  ```
* Stop Docker
  ```
  sudo docker stop v2ray
  ```
* Display links and QR codes (Attention: There is no official standards for VLESS link or QR code, you need modify it manually before use)
  ```
  docker exec -i -t v2ray node link-qrcode.js
  ```  

Thanks for the inspiration from https://github.com/pengchujin/v2rayDocker
