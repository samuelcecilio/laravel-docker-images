#!/bin/bash
composer install --no-ansi --no-interaction --no-scripts --optimize-autoloader
php artisan optimize:clear
php artisan migrate --no-interaction --force
supervisord -c docker/supervisord.local.conf
