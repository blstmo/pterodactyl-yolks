FROM --platform=$TARGETOS/$TARGETARCH eclipse-temurin:17-jdk-jammy

LABEL author="Alex Chatham" maintainer="info@blstmo.com"
LABEL org.opencontainers.image.source="https://github.com/blstmo/pterodactyl-yolks"
LABEL org.opencontainers.image.licenses=MIT

# Remove unwanted binaries
RUN rm -rf /usr/bin/dd \
    && rm -rf /usr/bin/fallocate \
    && rm -rf /usr/bin/truncate \
    && rm -rf /usr/bin/xfs_mkfile

# Install curl
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Download MCAntiMalware.jar
RUN curl -sSL https://github.com/OpticFusion1/MCAntiMalware/releases/latest/download/MCAntiMalware.jar -o /MCAntiMalware.jar

# Install remaining packages and add user
RUN apt-get update && \
    apt-get install -y jq lsof ca-certificates openssl git tar sqlite3 fontconfig libfreetype6 tzdata iproute2 libstdc++6 && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -d /home/container -m container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./../entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]
