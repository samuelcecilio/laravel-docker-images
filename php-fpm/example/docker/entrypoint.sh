#!/bin/bash
php artisan optimize
php artisan migrate --no-interaction --force
supervisord -c docker/supervisord.conf
