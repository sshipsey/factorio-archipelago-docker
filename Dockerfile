FROM debian:stable-slim AS rcon-builder
RUN apt-get -q update \
    && DEBIAN_FRONTEND=noninteractive apt-get -qy install build-essential

WORKDIR /src
COPY rcon/ /src
RUN make

FROM debian:stable-slim
LABEL maintainer="https://github.com/sshipsey/factorio-docker-archipelago"

ARG USER=factorio
ARG GROUP=factorio
ARG PUID=845
ARG PGID=845

ENV PORT=34197 \
    RCON_PORT=27015 \
    PUID="$PUID" \
    PGID="$PGID" \
    FACTORIO_VERSION="2.0.28" \
    ARCHIPELAGO_VERSION="0.5.1"

ARG ARCHIPELAGO_PORT
ARG ARCHIPELAGO_SERVER

ENV ARCHIPELAGO_SERVER=${ARCHIPELAGO_SERVER}
ENV ARCHIPELAGO_PORT=${ARCHIPELAGO_PORT}

# Archipelago dependencies
RUN apt-get -q update && apt-get -qy install expect libmtdev1 python3-tk ffmpeg libsm6 libxext6 jq libsdl2-2.0 libsdl2-dev xclip ca-certificates curl pwgen xz-utils procps gettext-base --no-install-recommends

RUN addgroup --system --gid "$PGID" "$GROUP" \
    && adduser --system --uid "$PUID" --gid "$PGID" --no-create-home --disabled-password --shell /bin/sh "$USER"


RUN curl -sSL --no-progress-meter "https://api.github.com/repos/ArchipelagoMW/Archipelago/releases/tags/$ARCHIPELAGO_VERSION"  \
    | jq -r '.assets[] | select(.name | contains("linux-x86_64.tar.gz")).browser_download_url' \
    | xargs curl -sSL --no-progress-meter -o /tmp/archipelago.tar.gz \
    && tar -xzf /tmp/archipelago.tar.gz -C /opt \
    && rm /tmp/archipelago.tar.gz

RUN archive="/tmp/factorio_headless_x64_$FACTORIO_VERSION.tar.xz" \
    && mkdir -p /opt/Archipelago/factorio /factorio \
    && curl -sSL "https://www.factorio.com/get-download/$FACTORIO_VERSION/headless/linux64" -o "$archive" \
    && tar xf "$archive" --directory /opt/Archipelago \
    && chmod ugo=rwx /opt/Archipelago/factorio \
    && rm "$archive" \
    && mkdir -p /opt/Archipelago/factorio/config/ \
    && chown -R "$USER":"$GROUP" /opt/Archipelago/factorio /factorio

COPY files/*.* /

VOLUME /factorio
VOLUME /opt/Archipelago/factorio/mods
VOLUME /opt/Archipelago/factorio/saves
EXPOSE $PORT/udp $RCON_PORT/tcp
ENTRYPOINT ["/docker-entrypoint.sh"]