FROM --platform=$TARGETOS/$TARGETARCH eclipse-temurin:18-jdk-jammy

# Set noninteractive mode to avoid dpkg prompts
ENV DEBIAN_FRONTEND=noninteractive

LABEL author="Alex Chatham" maintainer="info@blstmo.com" \
      org.opencontainers.image.source="https://github.com/blstmo/pterodactyl-yolks" \
      org.opencontainers.image.licenses=MIT

# Install curl (clear apt cache to reduce image size)
RUN apt-get update -y && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Download MCAntiMalware.jar
RUN curl -sSL https://github.com/OpticFusion1/MCAntiMalware/releases/latest/download/MCAntiMalware.jar -o /MCAntiMalware.jar

# Install remaining packages with --no-install-recommends and clear cache; add user
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends jq lsof ca-certificates openssl git tar sqlite3 fontconfig libfreetype6 tzdata iproute2 libstdc++6 && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -d /home/container -m container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./../entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]
