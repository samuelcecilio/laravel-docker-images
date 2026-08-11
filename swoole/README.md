# swoole

PHP + Swoole + Caddy sobre Ubuntu, com as extensões usadas por aplicações Laravel
(Octane).

| Versão | Base | Tags |
| --- | --- | --- |
| [8.3](8.3/) | `ubuntu:22.04` | `samuelcecilio/swoole:8.3` |
| [8.4](8.4/) | `ubuntu:24.04` | `samuelcecilio/swoole:8.4` |
| [8.5](8.5/) | `ubuntu:24.04` | `samuelcecilio/swoole:8.5`, `samuelcecilio/swoole:latest` |

```bash
just build swoole 8.5    # build local
just push swoole 8.5     # build multi-arch + push
just push swoole         # todas as versões
```

Veja o [README da raiz](../README.md) para os demais comandos.
