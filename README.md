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
just build php-fpm 8.5    # build local (arch do host) para testar
just push                 # build multi-arch + push de tudo
just push php-fpm         # todas as versões do php-fpm
just push php-fpm 8.5     # uma imagem/versão específica
just push all 8.3         # todas as imagens na versão 8.3
just new 8.6              # cria 8.6/ copiando da versão latest, trocando a versão do PHP
```

`push` faz build e push num passo só — imagens multi-arch não podem ser carregadas
localmente antes do push. Use `build` para testar.

Cada alvo é validado antes de rodar: a pasta precisa existir e o `Dockerfile`
precisa instalar a versão do PHP que o nome da pasta declara.

O `push` exige ainda que a working tree esteja limpa, para não publicar uma tag a
partir de código não commitado — use `just dirty=1 push ...` para ignorar. O `build`
não tem essa exigência, justamente para testar mudanças antes de commitar.
