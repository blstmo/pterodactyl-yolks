FROM        --platform=$TARGETOS/$TARGETARCH eclipse-temurin:16-jdk-focal

LABEL       author="Alex Chatham" maintainer="info@blstmo.com"

LABEL       org.opencontainers.image.source="https://github.com/blstmo/pterodactyl-yolks"
LABEL       org.opencontainers.image.licenses=MIT


RUN 				apt-get update -y \
						&& apt-get install -y jq lsof ca-certificates openssl git tar sqlite3 fontconfig libfreetype6 tzdata iproute2 libstdc++6 \
						&& useradd -d /home/container -m container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
