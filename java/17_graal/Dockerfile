FROM --platform=$TARGETOS/$TARGETARCH ghcr.io/graalvm/jdk-community:17

# Set noninteractive to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

LABEL author="Alex Chatham" maintainer="info@blstmo.com" \
      org.opencontainers.image.source="https://github.com/blstmo/pterodactyl-yolks" \
      org.opencontainers.image.licenses=MIT

# Remove unwanted binaries
RUN rm -rf /usr/bin/dd \
    && rm -rf /usr/bin/fallocate \
    && rm -rf /usr/bin/truncate \
    && rm -rf /usr/bin/xfs_mkfile

# Update and install curl using microdnf
RUN microdnf update -y \
    && microdnf install -y curl

# Download MCAntiMalware.jar
RUN curl -sSL https://github.com/OpticFusion1/MCAntiMalware/releases/latest/download/MCAntiMalware.jar -o /MCAntiMalware.jar

# Install additional packages and create container user
RUN microdnf update -y \
    && microdnf install -y jq lsof ca-certificates openssl git tar sqlite fontconfig freetype tzdata iproute libstdc++ \
    && useradd -d /home/container -m container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./../entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]
