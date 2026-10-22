# Laravel Docker Images

Imagens base para aplicações Laravel, versionadas por versão do PHP.

## Estrutura

```
php-fpm/
  8.3/  8.4/  8.5/     # Dockerfile + Caddyfile por versão
  example/             # projeto de exemplo (Laravel + docker compose)
swoole/
  8.3/  8.4/  8.5/
```

Cada pasta de versão é independente — a `8.3` roda em `ubuntu:22.04`, as demais em
`ubuntu:24.04`. Atualizar uma versão nunca afeta as outras.

## Tags publicadas

| Pasta | Tags no Docker Hub |
| --- | --- |
| `<imagem>/8.3` | `samuelcecilio/<imagem>:8.3` |
| `<imagem>/8.4` | `samuelcecilio/<imagem>:8.4` |
| `<imagem>/8.5` | `samuelcecilio/<imagem>:8.5` + `:latest` |

A versão que recebe a tag `latest` é a variável `latest` no [`justfile`](justfile).

## Comandos

Requer [`just`](https://github.com/casey/just) e `docker buildx`.

```bash
just info                 # mostra imagens, versões e as tags que seriam publicadas
just build php-fpm 8.5    # build local multi-arch (amd64 + arm64) para testar
just push                 # build multi-arch + push de tudo
just push php-fpm         # todas as versões do php-fpm
just push php-fpm 8.5     # uma imagem/versão específica
just push all 8.3         # todas as imagens na versão 8.3
just new 8.6              # cria 8.6/ copiando da versão latest, trocando a versão do PHP
```

`build` gera amd64 e arm64 e carrega as duas no Docker local, sem publicar. Isso
exige o containerd image store do Docker e, num host x86_64, emulação arm64 via
QEMU (no Fedora: `sudo dnf install qemu-user-static`). A parte emulada é lenta.

Cada alvo é validado antes de rodar: a pasta precisa existir e o `Dockerfile`
precisa instalar a versão do PHP que o nome da pasta declara.

O `push` exige ainda que a working tree esteja limpa, para não publicar uma tag a
partir de código não commitado — use `just dirty=1 push ...` para ignorar. O `build`
não tem essa exigência, justamente para testar mudanças antes de commitar.

## Publicação pelo GitHub Actions

O workflow [`publish.yml`](.github/workflows/publish.yml) builda cada imagem em
runners nativos (amd64 e arm64, sem emulação) e publica o manifest multi-arch com as
mesmas tags do `just push`. Imagens, versões e `latest` vêm do `justfile` e das
pastas, então não há nada para atualizar no workflow ao criar uma versão nova.

| Evento | O que faz |
| --- | --- |
| push no `main` | publica só as pastas de versão alteradas; mudança no `justfile` ou no workflow publica tudo |
| pull request | só builda, não publica |
| toda segunda, 06:00 UTC | rebuilda e publica tudo sem cache, para pegar atualizações de segurança |
| manual (*Run workflow*) | igual ao `just push [imagem] [versão]`, com opção de ignorar o cache |

Mudanças só em `*.md` e em `example/` não disparam build.

O workflow precisa dos secrets `DOCKERHUB_USERNAME` e `DOCKERHUB_TOKEN` (um access
token do Docker Hub com permissão de escrita).
