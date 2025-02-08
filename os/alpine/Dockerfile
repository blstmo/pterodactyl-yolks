FROM        --platform=$TARGETOS/$TARGETARCH alpine:latest
LABEL       author="Alex Chatham" maintainer="info@blstmo.com"
LABEL       org.opencontainers.image.source="https://github.com/blstmo/pterodactyl-yolks"
LABEL       org.opencontainers.image.licenses=MIT
RUN         apk add --update --no-cache ca-certificates curl unzip tar git jq wget && \
            echo -e "\033[38;5;47m██████╗ ██╗     ███████╗████████╗███╗   ███╗ ██████╗     ██████╗ ██████╗ ███╗   ███╗\n\
██╔══██╗██║     ██╔════╝╚══██╔══╝████╗ ████║██╔═══██╗   ██╔════╝██╔═══██╗████╗ ████║\n\
██████╔╝██║     ███████╗   ██║   ██╔████╔██║██║   ██║   ██║     ██║   ██║██╔████╔██║\n\
██╔══██╗██║     ╚════██║   ██║   ██║╚██╔╝██║██║   ██║   ██║     ██║   ██║██║╚██╔╝██║\n\
██████╔╝███████╗███████║   ██║   ██║ ╚═╝ ██║╚██████╔╝██╗╚██████╗╚██████╔╝██║ ╚═╝ ██║\n\
╚═════╝ ╚══════╝╚══════╝   ╚═╝   ╚═╝     ╚═╝ ╚═════╝ ╚═╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝\033[0m" > /etc/motd