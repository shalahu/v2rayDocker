[中文](#功能简介 "中文") | [English](#Features "English")

# v2rayDocker = v2ray (vmess + ws + tls) / xray (VLESS + tcp + xtls & VLESS + ws + tls & trojan + tcp + tls) / trojan (trojan + tcp + tls) + caddy2 + qrcode

## 功能简介

* 同时支持三种核心（默认 xray 作为 core_type）： 
	- v2ray（vmess + ws + tls）
	- xray（VLESS + tcp + xtls & VLESS + ws + tls & trojan + tcp + tls，三种协议同时运行）
	- trojan（trojan + tcp + tls），
* 自动生成 user_id、 ws_path （ws_path 亦是 trojan_password） 和 user_alertId （仅限 vmess），也支持自定义
* 与 v2ray 搭配时，默认使用 caddy2 自动生成证书
* 自动生成 安卓 v2rayNG vmess 链接和二维码
* 自动生成 iOS shadowrocket vmess 链接和二维码
* 已屏蔽非相关文件的访问
* 选择 xray 时使用共享内存高效进程转发（相比较与端口转发）

## 组件版本

* dockerhub: c258c4fff5f9/v2ray_ws:v0.9.4
* v2ray: v4.40.1
* xray: v1.4.2
* trojan-go: v0.10.4
* Caddy: v2.4.3
* alpine: v3.14
* golang: v1.16.5

## 使用方法

* 提前准备
  #####  1. 给域名，如 www.yourdomain.com，添加 A 记录，确保正确解析到 Docker 所在服务器的 IP 地址。具体设置方法可参看：https://help.aliyun.com/knowledge_detail/29725.html
  #####  2. 确认运行环境 80 和 443 端口未被占用。可运行 lsof -i:80 和 lsof -i:443 检查。
  #####  3. 当选择 xray （搭配 trojan 协议） 或 trojan 时确保 Docker 所在服务器存在以下两个文件（路径中的 ws_domain 需替换成自己的域名）
  ```
  "$HOME/.caddy/acme/acme-v02.api.letsencrypt.org/sites/ws_domain/ws_domain.crt"
  ```
  ```
  "$HOME/.caddy/acme/acme-v02.api.letsencrypt.org/sites/ws_domain/ws_domain.key"
  ```
  #####  否则会出现
  ```
  Error: No such container: v2ray
  ```
  #####  这个两个文件可通过运行一次 v2ray（vmess + ws + tls）从 letsencrypt 自动获取（或从其他位置复制）。
  #####  确保 v2ray 可以正常运行后，进入 docker
  ```
  docker exec -i -t v2ray bash
  ```
  #####  将证书复制到指定位置（路径中的 www.yourdomain.com 需替换成自己的域名）。注意：此操作是将 Docker 内的证书文件复制到和 Docker 所在服务器共享的文件夹中，以便留作后用。因此，启动 docker 前，需将 SELinux 设为 permissive 模式。
  ```
  cp -r $HOME/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/www.yourdomain.com /root/.caddy/acme/acme-v02.api.letsencrypt.org/sites
  ```
  #####  复制完成后，便可停掉当前 docker，并选择其他核心了。
* 安装 Docker 
  ```
  curl -fsSL https://get.docker.com -o get-docker.sh && bash get-docker.sh
  ```
* 启动 Docker
  ##### 1. 命令行参数：
  ```
  sudo docker run -d --rm --name v2ray -p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy c258c4fff5f9/v2ray_ws:v0.9.4 ws_domain(add/host) ws_name(ps) [user_id(id)] [ws_path/trojan_password(path)] [user_alertId(aid)] [core_type(bin)] && sleep 3s && sudo docker logs v2ray
  ```
  ##### 2. 务必将 ws_domain 替换成自己的域名，如 www.yourdomain.com。
  ##### 3. 可留空（将会自动生成）或自行替换 user_id （如 0890b53a-e3d4-4726-bd2b-52574e8588c4）、 ws_path （如 3o38nn5h）和 user_alertId (如 0，仅限 vmess)。
  ##### 4. 当选择 xray （搭配 trojan 协议）或 trojan 做为 core_type 时，ws_path 值将做为 trojan_password 使用。
  ##### 5. 默认 core_type 为 xray，可选 v2ray 或 trojan。
  ##### 6. 完整示例： 
  ```
  sudo docker run -d --rm --name v2ray -p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy c258c4fff5f9/v2ray_ws:v0.9.4 www.yourdomain.com V2RAY_WS 0890b53a-e3d4-4726-bd2b-52574e8588c4 3o38nn5h 0 xray && sleep 3s && sudo docker logs v2ray
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

# v2rayDocker = v2ray (vmess + ws + tls) / xray (VLESS + tcp + xtls & VLESS + ws + tls & trojan + tcp + tls) / trojan (trojan + tcp + tls) + caddy2 + qrcode

## Features

* Supporting 3 core types (take xray as core_type by default): 
	- v2ray (vmess + ws + tls)
	- xray (VLESS + tcp + xtls & VLESS + ws + tls & trojan + tcp + tls, 3 protocols are running side by side)
	- trojan (trojan + tcp + tls),  
* Auto generate user_id, ws_path (take ws_path as trojan_password) and user_alertId (only for vmess)，which also can be customized
* Auto generate CA by caddy2 when working with v2ray
* Auto generate vmess link and QR code for v2rayNG on Android
* Auto generate vmess link and QR code for shadowrocket on iOS
* Block access from nonessential files
* Use Shared Memory high performance process forwarding (comparing to port forwarding) when working with xray

## Module Verions

* dockerhub: c258c4fff5f9/v2ray_ws:v0.9.4
* v2ray: v4.40.1
* xray: v1.4.2
* trojan-go: v0.10.4
* Caddy: v2.4.3
* alpine: v3.14
* golang: v1.16.5

## How To Run

* Prerequisites
  #####  1. Create an A record for the domain, e.g. www.yourdomain.com, with the IP of docker server.  
  #####  2. port 80 and 443 should be available, check them with lsof -i:80 and lsof -i:443 on the server.
  #####  3. Make sure both files (replace ws_domain in the path with your domain), as follows, exist on docker server when choose xray (with trojan protocol) or trojan
  ```
  "$HOME/.caddy/acme/acme-v02.api.letsencrypt.org/sites/ws_domain/ws_domain.crt"
  ```
  ```
  "$HOME/.caddy/acme/acme-v02.api.letsencrypt.org/sites/ws_domain/ws_domain.key"
  ```
  #####  otherwise you will see
  ```
  Error: No such container: v2ray
  ```
  #####  you could get these 2 files from letsencrypt with running v2ray (vmess + ws + tls) once (or just copying from other locations).
  #####  after v2ray running properly, enter docker
  ```
  docker exec -i -t v2ray bash
  ```
  #####  Copy those 2 file to target locations (replace www.yourdomain.com in the path with your domain). Note：this procedure will copy certificates files from docker inside into a folder shared with docker server outside, so files can be kept and reused later. Must set SELinux to permissive model before start docker.
  ```
  cp -r $HOME/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/www.yourdomain.com /root/.caddy/acme/acme-v02.api.letsencrypt.org/sites
  ```
  #####  After copy, current docker can be stopped and continue with other core types.
* Install Docker 
  ```
  curl -fsSL https://get.docker.com -o get-docker.sh && bash get-docker.sh
  ```
* Start Docker
  ##### 1. Command line arguments:
  ```
  sudo docker run -d --rm --name v2ray -p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy c258c4fff5f9/v2ray_ws:v0.9.4 ws_domain(add/host) ws_name(ps) [user_id(id)] [ws_path/trojan_password(path)] [user_alertId(aid)] [core_type(bin)] && sleep 3s && sudo docker logs v2ray
  ```
  ##### 2. Must replace ws_domain with your domain, e.g. www.yourdomain.com.
  ##### 3. Keep user_id (e.g. 0890b53a-e3d4-4726-bd2b-52574e8588c4), ws_path (e.g. 3o38nn5h) and user_alertId (e.g. 0, only for vmess) empty (which will be auto-generated) or replace them by your own.
  ##### 4. The value of ws_path will used as trojan_password when choose xray (with trojan protocol) or trojan as core_type.
  ##### 5. Take xray as core_type by default, could repalce it by v2ray or trojan.
  ##### 6. Full example:
  ```
  sudo docker run -d --rm --name v2ray -p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy c258c4fff5f9/v2ray_ws:v0.9.4 www.yourdomain.com V2RAY_WS 0890b53a-e3d4-4726-bd2b-52574e8588c4 3o38nn5h 0 xray && sleep 3s && sudo docker logs v2ray
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
