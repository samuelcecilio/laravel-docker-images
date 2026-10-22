set shell := ["bash", "-euo", "pipefail", "-c"]

registry  := "samuelcecilio"
platforms := "linux/amd64,linux/arm64"
images    := "php-fpm swoole"

# version that also gets the :latest tag
latest := "8.5"

# allow publishing from a dirty working tree: `just dirty=1 push`
dirty := "0"

_default:
    @just --list --unsorted

# List existing images/versions and the tags that would be published
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

# Local multi-arch build (amd64 + arm64) for testing, without publishing. No args builds everything
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

# Multi-arch build + push to Docker Hub. No args publishes everything
push image="all" version="all":
    #!/usr/bin/env bash
    set -euo pipefail
    for img in $(just _targets {{image}}); do
        for v in $(just _versions "$img" {{version}}); do
            just _guard "$img" "$v"
            just _clean
            echo "==> push {{registry}}/$img:$v [{{platforms}}]"
            docker buildx build --platform {{platforms}} --pull --push $(just _tag_args "$img" "$v") "$img/$v"
            just _tag_args "$img" "$v" | tr ' ' '\n' | grep -v '^-t$' | sed 's/^/    published: /'
        done
    done

# Create a new version by copying another one (e.g. just new 8.6 8.5)
new version from=latest:
    #!/usr/bin/env bash
    set -euo pipefail
    for img in {{images}}; do
        if [ ! -d "$img/{{from}}" ]; then
            echo "error: $img/{{from}} does not exist" >&2
            exit 1
        fi
        if [ -d "$img/{{version}}" ]; then
            echo "error: $img/{{version}} already exists" >&2
            exit 1
        fi
        mkdir -p "$img/{{version}}"
        old='{{from}}'; old="${old//./\\.}"
        for f in "$img/{{from}}"/*; do
            sed "s/$old/{{version}}/g" "$f" > "$img/{{version}}/$(basename "$f")"
        done
        echo "created $img/{{version}} (from {{from}})"
    done
    echo
    echo "review the files and update 'latest' in the justfile if needed."

# Log in to Docker Hub
login:
    docker login -u {{registry}}

# --- internal ------------------------------------------------------------------

# Resolve "all" to the list of images
[private]
_targets image:
    @[ "{{image}}" = "all" ] && echo "{{images}}" || echo "{{image}}"

# Resolve "all" to the existing versions of the image
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

# -t arguments for buildx
[private]
_tag_args image version:
    #!/usr/bin/env bash
    set -euo pipefail
    args="-t {{registry}}/{{image}}:{{version}}"
    [ "{{version}}" = "{{latest}}" ] && args="$args -t {{registry}}/{{image}}:latest"
    echo "$args"

# Require a clean working tree; only before publishing, local builds do not need it
[private]
_clean:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{dirty}}" != "1" ] && [ -n "$(git status --porcelain)" ]; then
        echo "error: dirty working tree, refusing to publish. Commit first or run 'just dirty=1 push ...'" >&2
        exit 1
    fi

# Ensure the directory exists and the Dockerfile matches the directory version
[private]
_guard image version:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f "{{image}}/{{version}}/Dockerfile" ]; then
        echo "error: {{image}}/{{version}}/Dockerfile does not exist" >&2
        echo "       images: {{images}} | versions: $(just _versions {{image}} all 2>/dev/null | tr '\n' ' ')" >&2
        exit 1
    fi
    declared=$(grep -oE 'php8\.[0-9]+' "{{image}}/{{version}}/Dockerfile" | head -1 | sed 's/^php//')
    if [ "$declared" != "{{version}}" ]; then
        echo "error: {{image}}/{{version}}/Dockerfile installs php $declared, not {{version}}" >&2
        exit 1
    fi
