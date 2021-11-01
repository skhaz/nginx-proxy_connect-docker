FROM debian:stretch-slim AS base

FROM base AS builder

RUN apt-get update && apt-get install -y build-essential libpcre3-dev libssl-dev zlib1g-dev wget

WORKDIR /root/nginx

ARG NGINX_VERSION=1.21.3
RUN wget -qO- nginx.org/download/nginx-"$NGINX_VERSION".tar.gz | tar zx --strip-components=1

ARG PROXY_CONNECT_HASH=04f910be13f3b36d2ba1b95c0e18a234155df301
RUN mkdir ngx_http_proxy_connect_module
RUN wget -qO- github.com/chobits/ngx_http_proxy_connect_module/archive/"$PROXY_CONNECT_HASH".tar.gz | tar zx --strip-components=1 --directory ngx_http_proxy_connect_module
RUN patch -p1 < ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch

RUN ./configure --add-module=ngx_http_proxy_connect_module
RUN make -j$(nproc)

FROM base

RUN apt-get update && apt-get install -y gettext-base

COPY --from=builder /root/nginx/objs/nginx /usr/local/bin

RUN mkdir -p /usr/local/nginx/logs/ \
    && ln -sf /dev/stdout /usr/local/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/nginx/logs/error.log

ARG PORT=8000
ENV PORT $PORT
ENV HOST 0.0.0.0
EXPOSE $PORT

ADD nginx.conf /usr/local/nginx/conf/nginx.template

CMD sh -c "envsubst '\$PORT' < /usr/local/nginx/conf/nginx.template > /usr/local/nginx/conf/nginx.conf && nginx"
