#!/bin/bash

if [ "$APP_ENV" = "production" ]; then
    echo "Running on production environment"
    php artisan optimize
else
    composer install --no-ansi --no-interaction --no-scripts --optimize-autoloader
    php artisan optimize:clear
fi

php artisan migrate --no-interaction --force

chown -R laravel:laravel /var/www/html/storage
chown -R laravel:laravel /var/www/html/bootstrap/cache

exec supervisord -c /var/www/html/docker/supervisord.conf
