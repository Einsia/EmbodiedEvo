#!/usr/bin/env bash
# Optional wrapper around the standalone Dockerfile; no host Codex is needed.
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [image-tag]" >&2
  exit 2
fi
image="${1:-embodiedrsi-agent:latest}"
build_args=()
if [[ -n "${EMBODIEDRSI_BUILD_HTTP_PROXY:-}" ]]; then
  build_args+=(--build-arg "HTTP_PROXY=$EMBODIEDRSI_BUILD_HTTP_PROXY")
  build_args+=(--build-arg "HTTPS_PROXY=$EMBODIEDRSI_BUILD_HTTP_PROXY")
fi
for option in \
  BASE_IMAGE:EMBODIEDRSI_AGENT_BASE_IMAGE \
  NODE_IMAGE:EMBODIEDRSI_AGENT_NODE_IMAGE \
  CODEX_VERSION:EMBODIEDRSI_CODEX_VERSION \
  DEBIAN_MIRROR:EMBODIEDRSI_AGENT_DEBIAN_MIRROR \
  PIP_INDEX_URL:EMBODIEDRSI_AGENT_PIP_INDEX_URL \
  NPM_REGISTRY:EMBODIEDRSI_AGENT_NPM_REGISTRY; do
  variable="${option#*:}"
  if [[ -n "${!variable:-}" ]]; then
    build_args+=(--build-arg "${option%%:*}=${!variable}")
  fi
done
docker build --tag "$image" "${build_args[@]}" "$repo_root/docker/agent"
docker run --rm --network none "$image" codex --version
docker run --rm --network none "$image" python -c \
  'import numpy, PIL, imageio; print("Agent Python/image dependencies OK; no model request sent.")'
docker image inspect "$image" --format 'Agent image ready: {{.Id}}'
