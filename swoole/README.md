# swoole

PHP + Swoole + Caddy on Ubuntu, with the extensions used by Laravel applications
(Octane).

| Version | Base | Tags |
| --- | --- | --- |
| [8.3](8.3/) | `ubuntu:22.04` | `samuelcecilio/swoole:8.3` |
| [8.4](8.4/) | `ubuntu:24.04` | `samuelcecilio/swoole:8.4` |
| [8.5](8.5/) | `ubuntu:24.04` | `samuelcecilio/swoole:8.5`, `samuelcecilio/swoole:latest` |

```bash
just build swoole 8.5    # local build
just push swoole 8.5     # multi-arch build + push
just push swoole         # every version
```

See the [root README](../README.md) for the other commands.
