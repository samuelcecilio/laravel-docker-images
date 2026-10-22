set shell := ["bash", "-euo", "pipefail", "-c"]

registry  := "samuelcecilio"
platforms := "linux/amd64,linux/arm64"
images    := "php-fpm swoole"

# versão que também recebe a tag :latest
latest := "8.5"

# aceita build com working tree suja: `just dirty=1 push`
dirty := "0"

_default:
    @just --list --unsorted

# Mostra as imagens/versões existentes e as tags que seriam publicadas
info:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "registry:  {{registry}}"
    echo "platforms: {{platforms}}"
    echo "latest:    {{latest}}"
    echo
    for img in {{images}}; do
        for v in $(just _versions "$img" all); do
            tags="{{registry}}/$img:$v"
            [ "$v" = "{{latest}}" ] && tags="$tags, {{registry}}/$img:latest"
            printf "  %-22s -> %s\n" "$img/$v" "$tags"
        done
    done

# Build local multi-arch (amd64 + arm64) para testar, sem publicar. Sem args, builda tudo
build image="all" version="all":
    #!/usr/bin/env bash
    set -euo pipefail
    for img in $(just _targets {{image}}); do
        for v in $(just _versions "$img" {{version}}); do
            just _guard "$img" "$v"
            echo "==> build local {{registry}}/$img:$v [{{platforms}}]"
            docker buildx build --platform {{platforms}} --load $(just _tag_args "$img" "$v") "$img/$v"
        done
    done

# Build multi-arch + push pro Docker Hub. Sem args, publica tudo
push image="all" version="all":
    #!/usr/bin/env bash
    set -euo pipefail
    for img in $(just _targets {{image}}); do
        for v in $(just _versions "$img" {{version}}); do
            just _guard "$img" "$v"
            just _clean
            echo "==> push {{registry}}/$img:$v [{{platforms}}]"
            docker buildx build --platform {{platforms}} --pull --push $(just _tag_args "$img" "$v") "$img/$v"
            just _tag_args "$img" "$v" | tr ' ' '\n' | grep -v '^-t$' | sed 's/^/    publicado: /'
        done
    done

# Cria uma versão nova copiando de outra (ex: just new 8.6 8.5)
new version from=latest:
    #!/usr/bin/env bash
    set -euo pipefail
    for img in {{images}}; do
        if [ ! -d "$img/{{from}}" ]; then
            echo "erro: $img/{{from}} não existe" >&2
            exit 1
        fi
        if [ -d "$img/{{version}}" ]; then
            echo "erro: $img/{{version}} já existe" >&2
            exit 1
        fi
        mkdir -p "$img/{{version}}"
        old='{{from}}'; old="${old//./\\.}"
        for f in "$img/{{from}}"/*; do
            sed "s/$old/{{version}}/g" "$f" > "$img/{{version}}/$(basename "$f")"
        done
        echo "criado $img/{{version}} (a partir de {{from}})"
    done
    echo
    echo "revise os arquivos e atualize 'latest' no justfile se for o caso."

# Login no Docker Hub
login:
    docker login -u {{registry}}

# --- internos ---------------------------------------------------------------

# Resolve "all" para a lista de imagens
[private]
_targets image:
    @[ "{{image}}" = "all" ] && echo "{{images}}" || echo "{{image}}"

# Resolve "all" para as versões existentes da imagem
[private]
_versions image version:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{version}}" != "all" ]; then
        echo "{{version}}"
    else
        find "{{image}}" -mindepth 1 -maxdepth 1 -type d -name '[0-9]*.[0-9]*' \
            -exec basename {} \; | sort -V
    fi

# Argumentos -t para o buildx
[private]
_tag_args image version:
    #!/usr/bin/env bash
    set -euo pipefail
    args="-t {{registry}}/{{image}}:{{version}}"
    [ "{{version}}" = "{{latest}}" ] && args="$args -t {{registry}}/{{image}}:latest"
    echo "$args"

# Exige working tree limpa — só antes de publicar, build local não precisa
[private]
_clean:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{dirty}}" != "1" ] && [ -n "$(git status --porcelain)" ]; then
        echo "erro: working tree suja, não vou publicar. Commite ou rode 'just dirty=1 push ...'" >&2
        exit 1
    fi

# Garante que a pasta existe e que o Dockerfile bate com a versão da pasta
[private]
_guard image version:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f "{{image}}/{{version}}/Dockerfile" ]; then
        echo "erro: {{image}}/{{version}}/Dockerfile não existe" >&2
        echo "      imagens: {{images}} | versões: $(just _versions {{image}} all 2>/dev/null | tr '\n' ' ')" >&2
        exit 1
    fi
    declared=$(grep -oE 'php8\.[0-9]+' "{{image}}/{{version}}/Dockerfile" | head -1 | sed 's/^php//')
    if [ "$declared" != "{{version}}" ]; then
        echo "erro: {{image}}/{{version}}/Dockerfile instala php $declared, não {{version}}" >&2
        exit 1
    fi
