#!/bin/bash

HOST_DOMAIN="host.docker.internal"
if ! ping -q -c1 $HOST_DOMAIN > /dev/null 2>&1
then
 HOST_IP=$(ip route | awk 'NR==1 {print $3}')
 # shellcheck disable=SC2039
 echo -e "$HOST_IP\t$HOST_DOMAIN" >> /etc/hosts
fi

if [ -e composer.json ]; then \
      echo "installing php dependencies"; \
      composer install --no-progress; \
      composer require --dev cs-fixer-shim; \
      composer require --dev phpstan/phpstan; \
      composer require --dev phpstan/extension-installer; \
      composer require --dev phpstan/phpstan-symfony; \
      composer require --dev phpstan/phpstan-doctrine; \
      composer require --dev symfony/test-pack; \
fi

if [ -e package.json ]; then \
      echo "installing js dependencies"; \
      yarn install; \
      yarn run dev; \
fi
