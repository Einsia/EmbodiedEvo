#!/usr/bin/env bash
# Build a thin CLI image from the operator's installed standalone Codex release.
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
codex_binary="${1:-$(command -v codex)}"
image="${2:-embodiedrsi-agent:latest}"
build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT
cp "$repo_root/docker/agent/Dockerfile" "$build_dir/Dockerfile"
mkdir "$build_dir/bin"
cp -L "$codex_binary" "$build_dir/bin/codex"
# Recent releases execute code-mode tools in a sibling host binary. Copy only
# this release's CLI executables, never its config, credentials or session data.
codex_release_bin="$(dirname "$(readlink -f "$codex_binary")")"
if [[ -f "$codex_release_bin/codex-code-mode-host" ]]; then
  cp -L "$codex_release_bin/codex-code-mode-host" "$build_dir/bin/"
fi
proxy_args=()
if [[ -n "${EMBODIEDRSI_BUILD_HTTP_PROXY:-}" ]]; then
  proxy_args+=(--build-arg "HTTP_PROXY=$EMBODIEDRSI_BUILD_HTTP_PROXY")
  proxy_args+=(--build-arg "HTTPS_PROXY=$EMBODIEDRSI_BUILD_HTTP_PROXY")
fi
docker build --tag "$image" "${proxy_args[@]}" \
  --build-arg "BASE_IMAGE=${EMBODIEDRSI_AGENT_BASE_IMAGE:-python:3.11-slim-bookworm}" \
  --build-arg "DEBIAN_MIRROR=${EMBODIEDRSI_AGENT_DEBIAN_MIRROR:-https://deb.debian.org}" \
  --build-arg "PIP_INDEX_URL=${EMBODIEDRSI_AGENT_PIP_INDEX_URL:-https://pypi.org/simple}" \
  "$build_dir"
docker run --rm --network none "$image" codex --version
if [[ -f "$build_dir/bin/codex-code-mode-host" ]]; then
  docker run --rm --network none "$image" test -x /usr/local/bin/codex-code-mode-host
fi
