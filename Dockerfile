ARG PHP_VERSION

FROM php:7.3-fpm
#FROM php:${PHP_VERSION}-fpm

LABEL Maintainer="Radoslav Stefanov <radoslav@rstefanov.info>" \
      Description="Lightweight container with Nginx and PHP-FPM, based on Alpine Linux."

# Install system dependencies
RUN apt-get update && apt-get install -y zip libzip-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) zip

RUN docker-php-ext-install -j$(nproc) pdo pdo_mysql iconv mysqli

#RUN if [ "$(echo ${PHP_VERSION} | sed -e 's/\([0-9]\.[0-9]\).*/\1/')" = "7.4" ]; then \
#    docker-php-ext-configure gd --with-jpeg --with-freetype \
#      && docker-php-ext-install gd; \
#    fi

ENV PHP_VERSION=7.3
RUN mkdir -p /usr/local/lib && curl -sSlL  -o /tmp/ioncube.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && tar -x --strip-components=1 -C /usr/local/lib -f /tmp/ioncube.tar.gz ioncube/ioncube_loader_lin_${PHP_VERSION}.so

RUN mv /usr/local/lib/ioncube_loader_lin_7.3.so /usr/local/lib/php/extensions/no-debug-non-zts-20180731/ioncube_loader_lin_7.3.so

#RUN if [ "$(echo ${PHP_VERSION} | sed -e 's/\([0-9]\.[0-9]\).*/\1/')" = "7.3" ]; then \
#    docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr \
#      && docker-php-ext-install gd; \
#    fi

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN touch /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 10240M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 10240M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_input_time = 7200" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_execution_time = 7200" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "memory_limit = 512M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_input_vars = 2048" >> /usr/local/etc/php/conf.d/uploads.ini
