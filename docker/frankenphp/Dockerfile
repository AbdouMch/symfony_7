FROM dunglas/frankenphp:1-builder-php8.2.18-bookworm

ARG USER=www-data

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    gnupg2 \
    lsb-release \
    iproute2 \
    bash \
    git \
    libicu-dev \
    g++ \
    libpng-dev \
    libxml2-dev \
    libzip-dev \
    libonig-dev \
    libxslt-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSk https://getcomposer.org/installer | php -- --disable-tls && \
   mv composer.phar /usr/local/bin/composer

# install symfony cli
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash \
    && apt-get install -y symfony-cli

RUN pecl install apcu \
	&& pecl install xdebug-3.3.1 \
    && pecl clear-cache \
	&& docker-php-ext-enable apcu \
    xdebug \
    opcache \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure sysvsem --enable-sysvsem \
    && install-php-extensions  \
    gd  \
    intl  \
    zip  \
    calendar  \
    dom  \
    mbstring  \
    zip  \
    gd  \
    xsl  \
    sysvsem;

# install dependencies
COPY ./install-vendors.sh /usr/local/bin/install-vendors.sh
RUN chmod +x /usr/local/bin/install-vendors.sh
RUN /usr/local/bin/install-vendors.sh

COPY ../../ /app/public

WORKDIR /app/public