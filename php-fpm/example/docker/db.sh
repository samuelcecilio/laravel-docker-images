#!/usr/bin/env bash
mysql --user=root --password="" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS laravel_testing;
    GRANT ALL PRIVILEGES ON \`laravel_testing%\`.* TO 'laravel'@'%';
EOSQL
