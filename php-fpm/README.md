# php-fpm

Build
```
docker buildx build --platform linux/amd64,linux/arm64 \
  -t samuelcecilio/php-fpm:latest \
  -t samuelcecilio/php-fpm:8.4 \
  .
```

Push
```
docker push samuelcecilio/php-fpm:latest
docker push samuelcecilio/php-fpm:8.4
```
