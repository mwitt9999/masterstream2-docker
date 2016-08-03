FROM php:7.0-fpm

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    php-pear \
    wget

COPY xdebug-install.sh /xdebug-install.sh
RUN  cd / && sh xdebug-install.sh
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

# Type docker-php-ext-install to see available extensions
RUN docker-php-ext-install pdo pdo_mysql

RUN echo 'alias sf="php bin/console"' >> ~/.bashrc

RUN usermod -u 1000 www-data

WORKDIR /var/www/masterstream
