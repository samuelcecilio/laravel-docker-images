# php-fpm

PHP-FPM + Caddy sobre Ubuntu, com as extensões usadas por aplicações Laravel.

| Versão | Base | Tags |
| --- | --- | --- |
| [8.3](8.3/) | `ubuntu:22.04` | `samuelcecilio/php-fpm:8.3` |
| [8.4](8.4/) | `ubuntu:24.04` | `samuelcecilio/php-fpm:8.4` |
| [8.5](8.5/) | `ubuntu:24.04` | `samuelcecilio/php-fpm:8.5`, `samuelcecilio/php-fpm:latest` |

```bash
just build php-fpm 8.5    # build local
just push php-fpm 8.5     # build multi-arch + push
just push php-fpm         # todas as versões
```

Veja o [README da raiz](../README.md) para os demais comandos.

## Exemplo

[`example/`](example/) traz um projeto Laravel completo (Dockerfile multi-stage com
targets `local`/`production`, `docker-compose.yml` com MySQL, Redis, MinIO e Mailpit).
Está fixado na **8.4** — ajuste o `FROM` e os caminhos `/etc/php/8.x/` se for usar
outra versão.
