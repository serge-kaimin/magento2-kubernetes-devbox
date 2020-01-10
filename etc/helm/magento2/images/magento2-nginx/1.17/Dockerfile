FROM nginx:1.17
LABEL maintainer="serge.kaimin@gmail.com"

RUN groupadd -g 1000 app \
 && useradd -g 1000 -u 1000 -d /var/www -s /bin/bash app
RUN touch /var/run/nginx.pid
RUN mkdir /sock

RUN apt-get update && apt-get install -y openssl
RUN mkdir /etc/nginx/certs \
  && echo -e "\n\n\n\n\n\n\n" | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certs/nginx.key -out /etc/nginx/certs/nginx.crt

COPY ./conf/magento2.conf /etc/nginx/
COPY ./conf/default.conf /etc/nginx/conf.d/

#On CentOS, this is typically /var/www/html/magento. On Ubuntu, it is typically /var/www/magento.
RUN mkdir -p /etc/nginx/html /var/www/magento2 \
  && chown -R app:app /etc/nginx /var/www /var/www/magento2 /var/cache/nginx /var/run/nginx.pid /sock

EXPOSE 80 443

USER app:app

#VOLUME /var/www

WORKDIR /var/www/magento2