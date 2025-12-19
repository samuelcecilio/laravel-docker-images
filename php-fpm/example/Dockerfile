FROM samuelcecilio/php-fpm:8.4 AS base

WORKDIR /var/www/html

ARG USER_ID=1000
ARG GROUP_ID=1000

ENV PHP_MEMORY_LIMIT=512M \
    COMPOSER_MEMORY_LIMIT=512M

RUN userdel -r ubuntu \
    && groupadd --force -g $GROUP_ID laravel \
    && useradd -ms /bin/bash --no-user-group -g laravel -G www-data -u $USER_ID laravel \
    && mkdir -p /run/php && chown laravel:laravel /run/php

COPY ./docker/php.ini /etc/php/8.4/cli/conf.d/99-laravel.ini
COPY ./docker/www.conf /etc/php/8.4/fpm/pool.d/www.conf

COPY composer.lock composer.json /var/www/html/

RUN composer install \
    --no-ansi \
    --no-interaction \
    --no-scripts

COPY --chown=laravel:laravel . /var/www/html

RUN composer dump-autoload \
    --optimize \
    --working-dir=/var/www/html

FROM base AS local

RUN git config --global --add safe.directory /var/www/html

RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -y nodejs \
    && apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 8000
EXPOSE 5173

ENTRYPOINT ["sh", "/var/www/html/docker/entrypoint.sh"]

FROM node:20-alpine as assets

ARG VITE_APP_NAME

ENV VITE_APP_NAME=${VITE_APP_NAME}

WORKDIR /app

COPY package*.json ./
RUN npm ci

RUN printenv | grep VITE_ > .env

COPY . ./
RUN npm run build

FROM base AS production

# fix: JIT is incompatible with third party extensions that override zend_execute_ex().
RUN apt remove php8.4-pcov php8.4-xdebug -y

COPY --from=assets --chown=laravel:laravel /app/public /var/www/html/public

EXPOSE 8000

ENTRYPOINT ["sh", "/var/www/html/docker/entrypoint.sh"]
