# php-fpm

PHP-FPM + Caddy on Ubuntu, with the extensions used by Laravel applications.

| Version | Base | Tags |
| --- | --- | --- |
| [8.3](8.3/) | `ubuntu:22.04` | `samuelcecilio/php-fpm:8.3` |
| [8.4](8.4/) | `ubuntu:24.04` | `samuelcecilio/php-fpm:8.4` |
| [8.5](8.5/) | `ubuntu:24.04` | `samuelcecilio/php-fpm:8.5`, `samuelcecilio/php-fpm:latest` |

```bash
just build php-fpm 8.5    # local build
just push php-fpm 8.5     # multi-arch build + push
just push php-fpm         # every version
```

See the [root README](../README.md) for the other commands.

## Example

[`example/`](example/) contains a complete Laravel project (multi-stage Dockerfile
with `local`/`production` targets, `docker-compose.yml` with MySQL, Redis, RustFS and
Mailpit) and an `.env.example` wired to those services. It is pinned to **8.4**: update
the `FROM` line and the `/etc/php/8.x/` paths to use another version.
