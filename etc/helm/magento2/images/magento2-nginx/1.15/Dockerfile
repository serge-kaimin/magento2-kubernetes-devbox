FROM nginx:1.15-alpine as http
# https://github.com/usabilla/php-docker-template

# Add default user and group
RUN set -x \
    && addgroup -g 1000 app \
    && adduser -u 1000 -D -G app app

ARG NGINX_VHOST_TEMPLATE

# Env definition
ENV NGINX_DOCUMENT_ROOT="/var/www/magento2"
ENV NGINX_SERVER_NAME=localhost
ENV NGINX_PORT=80
ENV NGINX_WORKERS_PROCESSES=1
ENV NGINX_WORKERS_CONNECTIONS=1024
ENV NGINX_KEEPALIVE_TIMEOUT=65
ENV NGINX_EXPOSE_VERSION=off
ENV NGINX_CLIENT_BODY_BUFFER_SIZE=16k
ENV NGINX_CLIENT_MAX_BODY_SIZE=1m
ENV NGINX_LARGE_CLIENT_HEADER_BUFFERS="4 8k"
ENV NGINX_CORS_ENABLE=false
ENV NGINX_CORS_ALLOW_ORIGIN="*"

# Patch gCVE-2019-11068 (libxslt)
RUN apk upgrade --no-cache libxslt

# Nginx helper scripts
#COPY entrypoint.sh /entrypoint.sh
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
#RUN ln -s /usr/local/bin/docker-entrypoint.sh / # backwards compat

RUN mkdir -p /var/www/magento2/; \
    chown -R app.app /var/www/magento2/

# Nginx configuration filesg 
#COPY src/http/nginx/conf/main /etc/nginx/
COPY magento2.conf /etc/nginx/

WORKDIR /var/www/magento2

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

#CMD ["/entrypoint.sh"]

# Base images don't need healthcheck since they are not running applications
# this can be overriden in the child images
HEALTHCHECK NONE

FROM http as http-dev

ENV NGINX_EXPOSE_VERSION=on