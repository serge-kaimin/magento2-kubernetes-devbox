FROM php:7.3-fpm
LABEL maintainer="serge.kaimin@gmail.com"

# install libraries required by the extensions
RUN apt-get update && apt-get install -y \
    cron \
    apt-utils \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libxslt1-dev \
    libfreetype6-dev \
    libcurl4-gnutls-dev

# install extensions
# https://devdocs.magento.com/guides/v2.3/install-gde/system-requirements-tech.html#required-php-extensions
RUN docker-php-ext-configure gd --with-jpeg-dir --with-freetype-dir && \
    docker-php-ext-install \
      bcmath \
      ctype \
      curl \
      dom \
      gd \
      hash \
      iconv \
      intl \
      mbstring \
      openssl \
      pdo_mysql \
      simplexml \
      soap \
      spl \
      xsl \
      zip

RUN pecl channel-update pecl.php.net \
  && pecl install xdebug

RUN docker-php-ext-enable xdebug \
  && sed -i -e 's/^zend_extension/\;zend_extension/g' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

## Replace next lines with below commented out version once issue is resolved
# https://github.com/php/pecl-networking-ssh2/pull/36
# https://bugs.php.net/bug.php?id=78560
RUN curl -o /tmp/ssh2-1.2.tgz https://pecl.php.net/get/ssh2 \
  && pear install /tmp/ssh2-1.2.tgz \
  && rm /tmp/ssh2-1.2.tgz \
  && docker-php-ext-enable ssh2
#RUN pecl install ssh2-1.2 \
#  && docker-php-ext-enable ssh2

RUN groupadd -g 1000 app \
 && useradd -g 1000 -u 1000 -d /var/www -s /bin/bash app

RUN apt-get install -y gnupg \
  && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
  && apt-get install -y nodejs \
  && mkdir /var/www/.config /var/www/.npm \
  && chown app:app /var/www/.config /var/www/.npm \
  && ln -s /var/www/html/node_modules/grunt/bin/grunt /usr/bin/grunt

RUN curl -sSLO https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 \
  && chmod +x mhsendmail_linux_amd64 \
  && mv mhsendmail_linux_amd64 /usr/local/bin/mhsendmail

RUN curl -sS https://getcomposer.org/installer | \
  php -- --version=1.9.0 --install-dir=/usr/local/bin --filename=composer

#RUN curl -s https://packages.blackfire.io/gpg.key | apt-key add - \
#  && echo "deb http://packages.blackfire.io/debian any main" | tee /etc/apt/sources.list.d/blackfire.list \
#  && apt-get update \
#  && apt-get install blackfire-agent blackfire-php

RUN printf '* *\t* * *\tapp\t%s/usr/local/bin/php /var/www/magento2/update/cron.php\n' >> /etc/crontab \
  && printf '* *\t* * *\tapp\t%s/usr/local/bin/php /var/www/magento2/bin/magento cron:run\n' >> /etc/crontab \
  && printf '* *\t* * *\tapp\t%s/usr/local/bin/php /var/www/magento2/bin/magento setup:cron:run\n#\n' >> /etc/crontab

COPY conf/www.conf /usr/local/etc/php-fpm.d/
COPY conf/php.ini /usr/local/etc/php/
COPY conf/php-fpm.conf /usr/local/etc/
COPY cronstart.sh /usr/local/bin/cronstart

RUN mkdir -p /etc/nginx/html /var/www/html /sock \
  && chown -R app:app /etc/nginx /var/www /usr/local/etc/php/conf.d /sock

USER app:app

#VOLUME /var/www

WORKDIR /var/www/magento2

EXPOSE 9000