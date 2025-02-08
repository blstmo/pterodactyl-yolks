FROM        --platform=$TARGETOS/$TARGETARCH ubuntu:jammy
LABEL       author="Alex Chatham" maintainer="info@blstmo.com"
LABEL       org.opencontainers.image.source="https://github.com/blstmo/pterodactyl-yolks"
LABEL       org.opencontainers.image.licenses=MIT
ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt update \
            && apt upgrade -y \
            && apt -y --no-install-recommends install ca-certificates curl git unzip zip tar jq \
            && echo -e "\033[38;5;47m██████╗ ██╗     ███████╗████████╗███╗   ███╗ ██████╗     ██████╗ ██████╗ ███╗   ███╗\n\
██╔══██╗██║     ██╔════╝╚══██╔══╝████╗ ████║██╔═══██╗   ██╔════╝██╔═══██╗████╗ ████║\n\
██████╔╝██║     ███████╗   ██║   ██╔████╔██║██║   ██║   ██║     ██║   ██║██╔████╔██║\n\
██╔══██╗██║     ╚════██║   ██║   ██║╚██╔╝██║██║   ██║   ██║     ██║   ██║██║╚██╔╝██║\n\
██████╔╝███████╗███████║   ██║   ██║ ╚═╝ ██║╚██████╔╝██╗╚██████╗╚██████╔╝██║ ╚═╝ ██║\n\
╚═════╝ ╚══════╝╚══════╝   ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝\033[0m" > /etc/motd