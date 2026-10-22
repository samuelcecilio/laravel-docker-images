# Laravel Docker Images

Base images for Laravel applications, versioned by PHP version.

## Layout

```
php-fpm/
  8.3/  8.4/  8.5/     # Dockerfile + Caddyfile per version
  example/             # example project (Laravel + docker compose)
swoole/
  8.3/  8.4/  8.5/
```

Each version directory is independent: `8.3` runs on `ubuntu:22.04`, the others on
`ubuntu:24.04`. Updating one version never affects the others.

## Published tags

| Directory | Docker Hub tags |
| --- | --- |
| `<image>/8.3` | `samuelcecilio/<image>:8.3` |
| `<image>/8.4` | `samuelcecilio/<image>:8.4` |
| `<image>/8.5` | `samuelcecilio/<image>:8.5` + `:latest` |

The version that gets the `latest` tag is set by the `latest` variable in the
[`justfile`](justfile).

## Commands

Requires [`just`](https://github.com/casey/just) and `docker buildx`.

```bash
just info                 # list images, versions and the tags that would be published
just build php-fpm 8.5    # local multi-arch build (amd64 + arm64) for testing
just push                 # multi-arch build + push of everything
just push php-fpm         # every php-fpm version
just push php-fpm 8.5     # a single image/version
just push all 8.3         # every image at version 8.3
just new 8.6              # create 8.6/ by copying the latest version and replacing the PHP version
```

`build` produces amd64 and arm64 and loads both into the local Docker, without
publishing. This requires Docker's containerd image store and, on an x86_64 host,
arm64 emulation through QEMU (on Fedora: `sudo dnf install qemu-user-static`). The
emulated part is slow.

Every target is validated before running: the directory must exist and its
`Dockerfile` must install the PHP version that the directory name declares.

`push` also requires a clean working tree, so a tag is never published from
uncommitted code. Use `just dirty=1 push ...` to skip this check. `build` has no
such requirement, so you can test changes before committing them.

## Publishing with GitHub Actions

The [`publish.yml`](.github/workflows/publish.yml) workflow builds each image on
native runners (amd64 and arm64, no emulation) and publishes the multi-arch
manifest with the same tags as `just push`. Images, versions and `latest` are read
from the `justfile` and the directories, so the workflow needs no changes when you
add a version.

| Event | What it does |
| --- | --- |
| push to `main` | publishes only the changed version directories; a change to the `justfile` or the workflow publishes everything |
| pull request | builds only, does not publish |
| every Monday, 06:00 UTC | rebuilds and publishes everything without cache, to pick up security updates |
| manual (*Run workflow*) | same as `just push [image] [version]`, with an option to skip the cache |

Changes that only touch `*.md` files or `example/` do not trigger a build.

The workflow needs the `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets (a Docker
Hub access token with write permission).
