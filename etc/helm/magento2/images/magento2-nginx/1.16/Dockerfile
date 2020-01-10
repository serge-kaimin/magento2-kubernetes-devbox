FROM nginx:1.16-alpine
# stable release https://nginx.org/en/CHANGES-1.16

#COPY conf/nginx.conf /etc/nginx/
# https://github.com/dimadeush/docker-nginx-php-laravel/blob/master/Dockerfile
COPY magento2.conf /etc/nginx/sites-available/

RUN apk update \
    && apk upgrade \
    && apk add --no-cache openssl \
    && apk add --no-cache bash \
    && adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1

ARG UPSTREAM_CONTAINER=laravel-phpfpm
ARG UPSTREAM_PORT=9000

# Set upstream conf and remove the default conf
RUN echo "upstream php-upstream { server ${UPSTREAM_CONTAINER}:${UPSTREAM_PORT}; }" > /etc/nginx/conf.d/upstream.conf \
    && rm /etc/nginx/conf.d/default.conf

ADD ./start.sh /opt/start.sh
RUN sed -i 's/\r//g' /opt/start.sh
CMD ["/bin/bash", "/opt/start.sh"]

WORKDIR /var/www/magento2

EXPOSE 80 443