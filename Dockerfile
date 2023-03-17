FROM php:$PHP_VERSION-fpm

RUN echo ${PHP_VERSION}

RUN apt-get update && apt-get install -y \
        curl \
        wget \
        git \
        zip \
    && docker-php-ext-install -j$(nproc) iconv mbstring mysqli

RUN apt-get update && apt-get install -y libpng-dev
RUN apt-get install -y \
    libwebp-dev \
    libjpeg62-turbo-dev \
    libpng-dev libxpm-dev \
    libfreetype6-dev

RUN docker-php-ext-configure gd \
    --with-gd \
    --with-webp-dir \
    --with-jpeg-dir \
    --with-png-dir \
    --with-zlib-dir \
    --with-xpm-dir \
    --with-freetype-dir

RUN docker-php-ext-install gd

RUN apt-get install -y libzip-dev && docker-php-ext-configure zip --with-libzip=/usr/include && docker-php-ext-install zip

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www

USER 82:82

EXPOSE 9000

CMD ["php-fpm"]
