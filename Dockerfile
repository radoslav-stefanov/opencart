ARG PHP_VERSION

FROM php:7.3-fpm

LABEL Maintainer="Radoslav Stefanov <radoslav@rstefanov.info>" \
      Description="Lightweight container with Nginx and PHP-FPM, based on Ubuntu Linux."

RUN apt-get update && apt-get install -y zip libzip-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libwebp-dev libxml2-dev wget

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) zip

RUN docker-php-ext-install -j$(nproc) pdo pdo_mysql iconv mysqli soap

RUN docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-webp-dir=/usr  \
      && docker-php-ext-install gd

RUN mkdir /tmp/ioncube \
  && cd /tmp/ioncube \
  && wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
  && tar xvfz ioncube_loaders_lin_x86-64.tar.gz \
  && cp ioncube/ioncube_loader_lin_7.3.so /usr/local/lib/php/extensions/no-debug-non-zts-20180731/ioncube_loader_lin_7.3.so \
  && bash -c 'echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20180731/ioncube_loader_lin_7.3.so" > /usr/local/etc/php/conf.d/00-ionbube.ini'


RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN touch /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 10240M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 10240M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_input_time = 7200" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_execution_time = 7200" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "memory_limit = 512M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_input_vars = 2048" >> /usr/local/etc/php/conf.d/uploads.ini
