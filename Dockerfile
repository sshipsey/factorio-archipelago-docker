FROM debian:stable-slim AS rcon-builder
RUN apt-get -q update \
    && DEBIAN_FRONTEND=noninteractive apt-get -qy install build-essential

WORKDIR /src
COPY rcon/ /src
RUN make

FROM debian:stable-slim
LABEL maintainer="https://github.com/sshipsey/factorio-archipelago-docker"

ARG USER=factorio
ARG GROUP=factorio
ARG PUID=845
ARG PGID=845

ENV PORT=34197 \
    RCON_PORT=27015 \
    PUID="$PUID" \
    PGID="$PGID" \
    FACTORIO_VERSION="2.0.32" \
    ARCHIPELAGO_VERSION="0.5.1" \
    ARCHIPELAGO_SERVER="" \
    ARCHIPELAGO_PORT="" \
    FACTORIO_ADMIN=""
    
# Archipelago dependencies
RUN apt-get -q update && apt-get -qy install expect libmtdev1 python3-tk ffmpeg libsm6 libxext6 jq libsdl2-2.0 libsdl2-dev xclip ca-certificates curl pwgen xz-utils procps gettext-base --no-install-recommends

RUN addgroup --system --gid "$PGID" "$GROUP" \
    && adduser --system --uid "$PUID" --gid "$PGID" --no-create-home --disabled-password --shell /bin/sh "$USER"

COPY files/*.* /

VOLUME /factorio
VOLUME /opt/Archipelago/factorio/mods
VOLUME /opt/Archipelago/factorio/saves
EXPOSE $PORT/udp $RCON_PORT/tcp
ENTRYPOINT ["/docker-entrypoint.sh"]