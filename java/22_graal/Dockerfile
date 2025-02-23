FROM --platform=$TARGETOS/$TARGETARCH ghcr.io/graalvm/jdk-community:22

LABEL author="Alex Chatham" maintainer="info@blstmo.com"
LABEL org.opencontainers.image.source="https://github.com/blstmo/pterodactyl-yolks"
LABEL org.opencontainers.image.licenses=MIT

RUN rm -rf /usr/bin/dd \
    && rm -rf /usr/bin/fallocate \
    && rm -rf /usr/bin/truncate \
    && rm -rf /usr/bin/xfs_mkfile

RUN microdnf update -y \
    && microdnf install -y jq lsof ca-certificates openssl git tar sqlite fontconfig freetype tzdata iproute libstdc++ \
    && useradd -d /home/container -m container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./../entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]
