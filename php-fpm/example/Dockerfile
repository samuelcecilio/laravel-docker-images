FROM samuelcecilio/php-fpm:8.4 AS base

WORKDIR /var/www/html

ARG USER_ID=1000
ARG GROUP_ID=1000

ENV PHP_MEMORY_LIMIT=512M \
    COMPOSER_MEMORY_LIMIT=512M

RUN userdel -r ubuntu \
    && groupadd --force -g $GROUP_ID laravel \
    && useradd -ms /bin/bash --no-user-group -g laravel -G www-data -u $USER_ID laravel \
    && echo "laravel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/laravel \
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

EXPOSE 8000
EXPOSE 5173

ENTRYPOINT ["sh", "/var/www/html/docker/entrypoint.local.sh"]

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

COPY --from=assets --chown=laravel:laravel /app/public /var/www/html/public

EXPOSE 8000

USER laravel

ENTRYPOINT ["sh", "/var/www/html/docker/entrypoint.sh"]
