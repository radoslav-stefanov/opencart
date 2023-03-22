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

RUN set -eux \
	# Installation: Generic
	# Type:         Custom extension
	&& EXTENSION_DIR="$( php -i | grep ^extension_dir | awk -F '=>' '{print $2}' | xargs )" \
&& if [ ! -d "${EXTENSION_DIR}" ]; then mkdir -p "${EXTENSION_DIR}"; fi \
&& curl -sS --fail -k https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_$(dpkg-architecture --query DEB_HOST_GNU_CPU | sed 's/_/-/g').tar.gz -L -o ioncube.tar.gz \
&& tar xvfz ioncube.tar.gz \
&& cd ioncube \
&& cp "ioncube_loader_lin_7.3.so" "${EXTENSION_DIR}/ioncube.so" \
&& cd ../ \
&& rm -rf ioncube \
&& rm -rf ioncube.tar.gz \
 \
	&& true

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
