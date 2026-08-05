#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PATH="$HOME/.local/bin:$PATH"
export PATH
qdrant_image=qdrant/qdrant:v1.18.3
qdrant_container=grepai-qdrant
qdrant_volume=grepai-qdrant
embedding_model=nomic-embed-text-v2-moe

install_apt_package() {
  local package=$1

  if dpkg-query -W -f='${Status}' "$package" 2>/dev/null \
      | grep -qx 'install ok installed'; then
    printf 'already installed: %s\n' "$package"
    return
  fi

  sudo apt-get install -y "$package"
}

link_command() {
  local source=$1
  local target=$2

  mkdir -p -- "$(dirname -- "$target")"
  if [[ -L $target && $(readlink -f -- "$target") == $(readlink -f -- "$source") ]]; then
    printf 'already linked: %s\n' "$target"
    return
  fi
  if [[ -e $target || -L $target ]]; then
    printf 'cannot link %s: target already exists\n' "$target" >&2
    return 1
  fi
  ln -s -- "$source" "$target"
  printf 'linked: %s -> %s\n' "$target" "$source"
}

sudo apt-get update
install_apt_package docker.io
install_apt_package zstd

if ! command -v ollama >/dev/null 2>&1; then
  curl -fsSL https://ollama.com/install.sh | sh
else
  printf 'already installed: Ollama at %s\n' "$(command -v ollama)"
fi
sudo systemctl enable --now ollama

mkdir -p -- "$HOME/.local/bin"
if ! command -v grepai >/dev/null 2>&1; then
  curl -fsSL \
    https://raw.githubusercontent.com/yoanbernabeu/grepai/main/install.sh \
    | INSTALL_DIR="$HOME/.local/bin" sh
else
  printf 'already installed: grepai at %s\n' "$(command -v grepai)"
fi

if ! ollama list | awk 'NR > 1 {print $1}' \
    | grep -qx "${embedding_model}:latest"; then
  ollama pull "$embedding_model"
else
  printf 'already installed: Ollama model %s\n' "$embedding_model"
fi

sudo systemctl enable --now docker
sudo docker pull "$qdrant_image"
sudo docker volume create "$qdrant_volume" >/dev/null
if sudo docker container inspect "$qdrant_container" >/dev/null 2>&1; then
  sudo docker start "$qdrant_container" >/dev/null
  printf 'already configured: Qdrant container %s\n' "$qdrant_container"
else
  qdrant_security_options=()
  if [[ $(systemd-detect-virt --container 2>/dev/null || true) == lxc ]]; then
    qdrant_security_options+=(--security-opt apparmor=unconfined)
  fi
  sudo docker run --detach \
    --name "$qdrant_container" \
    --restart unless-stopped \
    "${qdrant_security_options[@]}" \
    --publish 127.0.0.1:6333:6333 \
    --publish 127.0.0.1:6334:6334 \
    --volume "$qdrant_volume:/qdrant/storage" \
    "$qdrant_image" >/dev/null
  printf 'started: Qdrant container %s\n' "$qdrant_container"
fi

for attempt in {1..30}; do
  if curl -fsS http://127.0.0.1:6333/healthz >/dev/null; then
    break
  fi
  if (( attempt == 30 )); then
    printf 'Qdrant did not become healthy\n' >&2
    exit 1
  fi
  sleep 1
done

link_command "$repo_dir/grepai-project-init" \
  "$HOME/.local/bin/grepai-project-init"

grepai_path=$(command -v grepai)
if command -v codex >/dev/null 2>&1; then
  if codex mcp get grepai >/dev/null 2>&1; then
    printf 'already configured: grepai MCP for Codex\n'
  else
    codex mcp add grepai -- "$grepai_path" mcp-serve
  fi
fi

if command -v claude >/dev/null 2>&1; then
  if claude mcp get grepai >/dev/null 2>&1; then
    printf 'already configured: grepai MCP for Claude Code\n'
  else
    claude mcp add grepai -- "$grepai_path" mcp-serve
  fi
else
  printf 'Claude Code is not installed; its MCP entry was not added\n'
fi

printf '\nReady. In a project, run: grepai-project-init\n'
