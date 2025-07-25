#!/bin/bash
ARCHI_DIR="/opt/Archipelago"
FACTORIO_DIR="$ARCHI_DIR/factorio"
ARCHI_CACHE_MARKER="$ARCHI_DIR/.archipelago_version"
FACTORIO_CACHE_MARKER="$FACTORIO_DIR/.factorio_version"


if [[ -f "$ARCHI_CACHE_MARKER" && "$(cat "$ARCHI_CACHE_MARKER")" == "$ARCHIPELAGO_VERSION" ]]; then
    echo "✅ Archipelago $ARCHIPELAGO_VERSION already present, skipping download."
else
    echo "📦 Downloading Archipelago $ARCHIPELAGO_VERSION..."
    mkdir -p "$ARCHI_DIR"

    ARCHI_URL=$(curl -sSL "https://api.github.com/repos/ArchipelagoMW/Archipelago/releases/tags/$ARCHIPELAGO_VERSION" \
      | jq -r '.assets[] | select(.name | contains("linux-x86_64.tar.gz")).browser_download_url')

    if [[ -z "$ARCHI_URL" ]]; then
        echo "❌ Failed to find Archipelago version: $ARCHIPELAGO_VERSION"
        exit 1
    fi

    curl -sSL "$ARCHI_URL" -o /tmp/archipelago.tar.gz
    tar -xzf /tmp/archipelago.tar.gz -C "/tmp"
    cp -r /tmp/Archipelago/* $ARCHI_DIR
    rm -r /tmp/Archipelago
    rm /tmp/archipelago.tar.gz

    echo "$ARCHIPELAGO_VERSION" > "$ARCHI_CACHE_MARKER"
fi


if [[ -f "$FACTORIO_CACHE_MARKER" && "$(cat "$FACTORIO_CACHE_MARKER")" == "$FACTORIO_VERSION" ]]; then
    echo "✅ Factorio $FACTORIO_VERSION already present, skipping download."
else
    echo "🎮 Downloading Factorio $FACTORIO_VERSION..."

    mkdir -p "$FACTORIO_DIR"
    mkdir -p /factorio

    ARCHIVE="/tmp/factorio_headless_x64_${FACTORIO_VERSION}.tar.xz"
    curl -sSL "https://www.factorio.com/get-download/$FACTORIO_VERSION/headless/linux64" -o "$ARCHIVE"
    tar -xf "$ARCHIVE" -C "$ARCHI_DIR"
    rm "$ARCHIVE"

    chmod -R ugo+rwx "$FACTORIO_DIR"
    mkdir -p "$FACTORIO_DIR/config"
    echo "$FACTORIO_VERSION" > "$FACTORIO_CACHE_MARKER"
    chown -R "$PUID:$PGID" "$FACTORIO_DIR" /factorio
fi


cd "$ARCHI_DIR"

cat <<EOF > factorio/data/server-adminlist.json
["$FACTORIO_ADMIN"]
EOF

/archi_factorio_expect.exp $ARCHIPELAGO_SERVER $ARCHIPELAGO_PORT