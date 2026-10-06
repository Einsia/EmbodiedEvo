ARG BASE_IMAGE=python:3.11-slim-bookworm
FROM ${BASE_IMAGE}
ARG DEBIAN_MIRROR=https://deb.debian.org
ARG PIP_INDEX_URL=https://pypi.org/simple
RUN sed -i "s|http://deb.debian.org|${DEBIAN_MIRROR}|g" /etc/apt/sources.list.d/debian.sources \
    && apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates git ripgrep ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir numpy pillow imageio \
    && mkdir -p /workspace /home/agent
COPY bin/ /usr/local/bin/
WORKDIR /workspace
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
