ARG CADDY_VERSION="2.3.0"
ARG GOLANG_IMAGE_VERSION="1.16.2-alpine"
ARG ALPINE_IMAGE_VERSION="3.13"

#
# Builder
#
FROM caddy:${CADDY_VERSION}-alpine as caddy-builder

FROM golang:${GOLANG_IMAGE_VERSION} as go-builder

RUN go get -v github.com/abiosoft/parent

#
# Final stage
#
FROM alpine:${ALPINE_IMAGE_VERSION}

ARG LOCAL_MODE
ENV LOCAL_MODE=${LOCAL_MODE:-"false"}

RUN if [ "${LOCAL_MODE}" = "true" ]; then sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; fi

# V2RAY
ARG V2RAY_VERSION
ENV V2RAY_INSTALL_VERSION=${V2RAY_VERSION:-"4.36.2"}

ARG V2RAY_GITHUB="https://github.com/v2fly/v2ray-core/releases/download/v${V2RAY_INSTALL_VERSION}/v2ray-linux-64.zip"
ARG V2RAY_FAST_GIT="https://download.fastgit.org/v2fly/v2ray-core/releases/download/v${V2RAY_INSTALL_VERSION}/v2ray-linux-64.zip"

ARG TIME_ZONE 
ENV SYSTEM_TIME_ZONE=${TIME_ZONE:-"Asia/Shanghai"}

RUN apk upgrade --update \
    && apk add \
        bash \
        tzdata \
        # curl \
    && mkdir -p \ 
       # /var/log/v2ray/ \
        /etc/v2ray/ \
        /tmp/v2ray \
    && if [ "$LOCAL_MODE" = "false" ]; then wget --no-cache -O /tmp/v2ray/v2ray.zip ${V2RAY_GITHUB}; else wget --no-cache -O /tmp/v2ray/v2ray.zip ${V2RAY_FAST_GIT}; fi \
    && pwd \
    && unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray/ \
    && mv /tmp/v2ray/v2ray /usr/bin \
    && mv /tmp/v2ray/v2ctl /usr/bin \
    && mv /tmp/v2ray/vpoint_vmess_freedom.json /etc/v2ray/config.json \
    && chmod +x /usr/bin/v2ray \
    && chmod +x /usr/bin/v2ctl \
    # && apk del curl \
    && ln -sf /usr/share/zoneinfo/${SYSTEM_TIME_ZONE} /etc/localtime \
    && echo ${SYSTEM_TIME_ZONE} > /etc/timezone \
    && rm -rf /tmp/v2ray /var/cache/apk/*

# ADD entrypoint.sh /entrypoint.sh
WORKDIR /srv
# node
# install node 
RUN apk add --no-cache util-linux
RUN apk add --update nodejs nodejs-npm
COPY package.json /srv/package.json
RUN npm install
COPY v2ray.js /srv/v2ray.js

ARG CADDY_VERSION
ENV CADDY_INSTALL_VERSION=${CADDY_VERSION:-"2.3.0"}

ARG GOLANG_IMAGE_VERSION
ENV GOLANG_IMAGE_VERSION="$GOLANG_IMAGE_VERSION"

ARG ALPINE_IMAGE_VERSION
ENV ALPINE_IMAGE_VERSION="$ALPINE_IMAGE_VERSION"

RUN apk add --no-cache \
    ca-certificates \
    git \
    mailcap \
    openssh-client \
    tzdata

# install caddy
COPY --from=caddy-builder /usr/bin/caddy /usr/bin/caddy

# validate install
RUN /usr/bin/caddy version
RUN /usr/bin/caddy list-modules


VOLUME /root/.caddy /srv
# WORKDIR /srv

COPY Caddyfile /etc/Caddyfile
COPY index.html /srv/index.html
# COPY package.json /etc/package.json
# install process wrapper
COPY --from=go-builder /go/bin/parent /bin/parent
ADD caddy.sh /caddy.sh
RUN ["chmod", "+x", "/caddy.sh"]
EXPOSE 443 80
ENTRYPOINT ["/caddy.sh"]
# CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=$ACME_AGREE"]
