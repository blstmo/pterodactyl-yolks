FROM debian:bookworm-slim AS builder

# Install deps for mimalloc building
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        which \
        lsof \
        curl \
        ca-certificates \
        openssl \
        git \
        tar \
        sqlite3 \
        fontconfig \
        libfreetype6 \
        tzdata \
        iproute2 \
        libstdc++6 \
        cmake \
        autoconf && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt /tmp/jprof /tmp/nmt /tmp/pmap /diagnostic

# We manually compile mimalloc here
WORKDIR /opt
RUN git clone https://github.com/microsoft/mimalloc && \
    cd mimalloc && \
    mkdir -p build && \
    cd build && \
    cmake -DMI_BUILD_TESTS=OFF ../ && \
    make install

FROM --platform=$TARGETOS/$TARGETARCH azul/zulu-openjdk-debian:25-latest

LABEL       author="Alex Chatham" maintainer="info@blstmo.com"

LABEL       org.opencontainers.image.source="https://github.com/blstmo/pterodactyl-yolks"
LABEL       org.opencontainers.image.licenses=MIT

RUN apt-get update -y && \
    apt-get install -y screen lsof curl ca-certificates openssl git tar sqlite3 fontconfig libfreetype6 tzdata iproute2 libstdc++6 && \
    useradd -d /home/container -m container

USER container
ENV USER=container \
    HOME=/home/container

WORKDIR /home/container/

# Changes: Copy compiled libmimalloc.so file to final image.
COPY --from=builder /usr/local/lib/libmimalloc.so /usr/local/lib/libmimalloc.so
COPY scripts/mimalloc.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
