FROM php:8-apache
MAINTAINER ctucker

RUN apt-get update && pecl install redis && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    default-mysql-client \
    libzip-dev \
    libonig-dev \
    zlib1g-dev \
    libicu-dev \
    g++ 
    
# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install mysqli pdo_mysql zip exif pcntl opcache bcmath tokenizer
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd && docker-php-ext-enable opcache redis
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

RUN apk add --no-cache --virtual .tz-build-deps $PHPIZE_DEPS \
      && pecl install timezonedb-2026.4 \
      && docker-php-ext-enable timezonedb \
      && apk del .tz-build-deps
	  
# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    
COPY ./config/expense.conf /etc/apache2/sites-available/expense.conf
COPY ./config/expense.php.ini /etc/apache2/conf.d/expense.php.ini
COPY start.sh /usr/local/bin/start
	
RUN mkdir -p /var/www/expense/current/public

RUN a2ensite expense.conf && a2dissite 000-default.conf && chmod u+x /usr/local/bin/start && a2enmod rewrite

WORKDIR /var/www/expense

CMD ["/usr/local/bin/start"]
