FROM php:7.4-fpm

RUN apt-get update && \
    apt-get install -y \
        libzip-dev \
        unzip \
        git \
        curl \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd pdo pdo_mysql zip && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY . /var/www/html

# Set COMPOSER_ALLOW_SUPERUSER to allow running Composer as root
ENV COMPOSER_ALLOW_SUPERUSER=1

# Modify the Composer configuration to include the "kylekatarnls/update-helper" package in the "allow-plugins" list
RUN composer global config allow-plugins.kylekatarnls/update-helper true

# Run composer update
RUN composer update

RUN php artisan key:generate

RUN cd /var/www/html && \
    sed -i 's/DB_HOST=127.0.0.1/DB_HOST=mysql-db/' .env && \
    sed -i 's/DB_DATABASE=homestead/DB_DATABASE=perpusku_gc/' .env && \
    sed -i 's/DB_USERNAME=homestead/DB_USERNAME=student/' .env && \
    sed -i 's/DB_PASSWORD=secret/DB_PASSWORD=admin/' .env

COPY php_artisan.sh /var/www/html/php_artisan.sh

RUN chmod +x /var/www/html/php_artisan.sh

EXPOSE 8000
