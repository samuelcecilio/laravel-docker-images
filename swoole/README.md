# swoole

Build
```
docker buildx build --platform linux/amd64,linux/arm64 \
  -t samuelcecilio/swoole:latest \
  -t samuelcecilio/swoole:8.4 \
  .
```

Push
```
docker push samuelcecilio/swoole:latest
docker push samuelcecilio/swoole:8.4
```
