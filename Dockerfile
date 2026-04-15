FROM python:3.11-slim

ARG SYNCPLAY_VERSION=1.7.5

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        make \
        tar \
        xz-utils \
        passwd \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/build

RUN curl -fsSL "https://github.com/Syncplay/syncplay/archive/refs/tags/v${SYNCPLAY_VERSION}.tar.gz" -o syncplay.tar.gz \
    && tar -xzf syncplay.tar.gz \
    && cd "syncplay-${SYNCPLAY_VERSION}" \
    && make install \
    && rm -rf /tmp/build

RUN groupadd --system syncplay \
    && useradd --system --gid syncplay --create-home --home-dir /home/syncplay syncplay

RUN pip install twisted

WORKDIR /app

COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER syncplay

EXPOSE 8999/tcp

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["syncplay-server"]
