#!/bin/bash
# FILE="/etc/Caddy"
domain="$1"
psname="$2"
uuid="51be9a06-299f-43b9-b713-1ec5eb76e3d7"
path="3o38nn5h"
if  [ ! "$3" ] ;then
    uuid=$(uuidgen)
    echo "uuid 将会系统随机生成"
else
    uuid="$3"
fi
if  [ ! "$4" ] ;then
    path=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
    echo "path 将会系统随机生成"
else
    path="$4"
fi

caddy1() {
	cat > /etc/Caddyfile <<'EOF'
	domain
	{
	  log ./caddy.log
	  proxy /onepath :2333 {
		websocket
		header_upstream -Origin
	  }
	  timeouts none
	  rewrite {
	  if_op or
	  if {file} ends_with .js
	  if {file} ends_with .log
	  if {file} ends_with .json
	  if {uri} starts_with /node_modules/
	  to /404
	  }
	}
EOF
}

caddy2() {
	cat > /etc/Caddyfile <<'EOF'
	{
	  debug
	}
	domain
	{
	  log {
		output file ./caddy.log {
		  roll_size 10mb
		  roll_keep 30
		  roll_keep_for 72h
		}
	  }
	  tls {
    	on_demand
	  }
	  reverse_proxy /onepath localhost:2333 {
		header_up Host {host}
		header_up X-Real-IP {remote_host}
		header_up X-Forwarded-For {remote_host}
		header_up X-Forwarded-Proto {scheme}
	  }
	  @blocked {
		path *.js *.log *.json /node_modules/*
	  }
	  respond @blocked 404
	  file_server
	}
EOF
}

# vsersion 2.0.0 and above needs to use a new Caddyfile
caddy_2=false
if [ "$(echo ${CADDY_VERSION} | cut -c1)" -eq 2 ] 2>/dev/null; then 
    caddy_2=true
fi

if $caddy_2; then 
    caddy2
else
	caddy1
fi

sed -i "s/domain/${domain}/" /etc/Caddyfile
sed -i "s/onepath/${path}/" /etc/Caddyfile

# v2ray
cat > /etc/v2ray/config.json <<'EOF'
{
  "inbounds": [
    {
      "port": 2333,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "uuid",
            "alterId": 64
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
        "path": "/onepath"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF

sed -i "s/uuid/${uuid}/" /etc/v2ray/config.json
sed -i "s/onepath/${path}/" /etc/v2ray/config.json

cat > /srv/sebs.js <<'EOF'
 {
    "add":"domain",
    "aid":"0",
    "host":"",
    "id":"uuid",
    "net":"ws",
    "path":"/onepath",
    "port":"443",
    "ps":"sebsclub",
    "tls":"tls",
    "type":"none",
    "v":"2"
  }
EOF

if [ "$psname" != "" ] && [ "$psname" != "-c" ]; then
  sed -i "s/sebsclub/${psname}/" /srv/sebs.js
  sed -i "s/domain/${domain}/" /srv/sebs.js
  sed -i "s/uuid/${uuid}/" /srv/sebs.js
  sed -i "s/onepath/${path}/" /srv/sebs.js
else
  $*
fi
pwd
cp /etc/Caddyfile .
nohup /bin/parent caddy run --environ &
echo "配置 JSON 详情"
echo " "
cat /etc/v2ray/config.json
echo " "
node v2ray.js
/usr/bin/v2ray -config /etc/v2ray/config.json
