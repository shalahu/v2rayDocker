ARG CADDY_VERSION="2.3.0"
ARG GOLANG_IMAGE_VERSION="1.16.2-alpine"
ARG ALPINE_IMAGE_VERSION="3.13"
ARG TROJAN_GO_IMAGE_VERSION="0.8.2"

#
# caddy stage
#
FROM caddy:${CADDY_VERSION}-alpine as caddy-builder

#
# go stage
#
FROM golang:${GOLANG_IMAGE_VERSION} as go-builder

RUN go get -v github.com/abiosoft/parent

#
# trojan-go stage
#
FROM teddysun/trojan-go:${TROJAN_GO_IMAGE_VERSION} as trojan-go-builder

#
# final stage
#
FROM alpine:${ALPINE_IMAGE_VERSION}

ARG LOCAL_MODE
ENV LOCAL_MODE=${LOCAL_MODE:-"false"}

RUN if [ "${LOCAL_MODE}" = "true" ]; then sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; fi

ARG CADDY_VERSION
ENV CADDY_INSTALL_VERSION=${CADDY_VERSION:-"2.3.0"}

ARG GOLANG_IMAGE_VERSION
ENV GOLANG_IMAGE_VERSION="$GOLANG_IMAGE_VERSION"

ARG ALPINE_IMAGE_VERSION
ENV ALPINE_IMAGE_VERSION="$ALPINE_IMAGE_VERSION"

ARG TROJAN_GO_IMAGE_VERSION
ENV TROJAN_GO_IMAGE_VERSION="$TROJAN_GO_IMAGE_VERSION"

# v2ray
ARG V2RAY_VERSION
ENV V2RAY_INSTALL_VERSION=${V2RAY_VERSION:-"4.36.2"}

ARG V2RAY_GITHUB="https://github.com/v2fly/v2ray-core/releases/download/v${V2RAY_INSTALL_VERSION}/v2ray-linux-64.zip"
ARG V2RAY_FAST_GIT="https://download.fastgit.org/v2fly/v2ray-core/releases/download/v${V2RAY_INSTALL_VERSION}/v2ray-linux-64.zip"

# xray
ARG XRAY_VERSION
ENV XRAY_INSTALL_VERSION=${XRAY_VERSION:-"1.4.0"}

ARG XRAY_GITHUB="https://github.com/XTLS/Xray-core/releases/download/v${XRAY_INSTALL_VERSION}/Xray-linux-64.zip"
ARG XRAY_FAST_GIT="https://download.fastgit.org/XTLS/Xray-core/releases/download/v${XRAY_INSTALL_VERSION}/Xray-linux-64.zip"

ARG TIME_ZONE 
ENV SYSTEM_TIME_ZONE=${TIME_ZONE:-"Asia/Shanghai"}

# install v2ray and xray
RUN apk upgrade --update \
    && apk add \
        bash \
        tzdata \
		util-linux \
		nodejs \
		nodejs-npm \
		ca-certificates \
		git \
		mailcap \
		openssh-client \
    && mkdir -p \ 
        /etc/v2ray/ \
        /tmp/v2ray \
		/etc/xray/ \
        /tmp/xray \
    && if [ "$LOCAL_MODE" = "false" ]; then wget --no-cache -O /tmp/v2ray/v2ray.zip ${V2RAY_GITHUB}; else wget --no-cache -O /tmp/v2ray/v2ray.zip ${V2RAY_FAST_GIT}; fi \
	&& if [ "$LOCAL_MODE" = "false" ]; then wget --no-cache -O /tmp/xray/xray.zip ${XRAY_GITHUB}; else wget --no-cache -O /tmp/xray/xray.zip ${XRAY_FAST_GIT}; fi \
    && pwd \
    && unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray/ \
    && mv /tmp/v2ray/v2ray /usr/bin \
    && mv /tmp/v2ray/v2ctl /usr/bin \
    && mv /tmp/v2ray/vpoint_vmess_freedom.json /etc/v2ray/config.json \
    && chmod +x /usr/bin/v2ray \
    && chmod +x /usr/bin/v2ctl \
	&& unzip /tmp/xray/xray.zip -d /tmp/xray/ \
	&& mv /tmp/xray/xray /usr/bin \
	&& mv /tmp/xray/geoip.dat /usr/bin \
	&& mv /tmp/xray/geosite.dat /usr/bin \
	&& chmod +x /usr/bin/xray \
    && ln -sf /usr/share/zoneinfo/${SYSTEM_TIME_ZONE} /etc/localtime \
    && echo ${SYSTEM_TIME_ZONE} > /etc/timezone \
    && rm -rf /tmp/v2ray /tmp/xray /var/cache/apk/*

WORKDIR /srv

# copy qrcode files
COPY package.json /srv/package.json
RUN npm install
COPY link-qrcode.js /srv/link-qrcode.js

# copy trojan-go

COPY --from=trojan-go-builder /usr/bin/trojan-go /usr/bin/trojan-go

# validate trojan-go
RUN /usr/bin/trojan-go -version 

# copy caddy
COPY --from=caddy-builder /usr/bin/caddy /usr/bin/caddy

# validate caddy
RUN /usr/bin/caddy version

# copy caddy other files
COPY Caddyfile /etc/Caddyfile
COPY index.html /srv/index.html

VOLUME /root/.caddy /srv

# install process wrapper
COPY --from=go-builder /go/bin/parent /bin/parent
ADD caddy.sh /caddy.sh
RUN ["chmod", "+x", "/caddy.sh"]

EXPOSE 443 80
ENTRYPOINT ["/caddy.sh"]
