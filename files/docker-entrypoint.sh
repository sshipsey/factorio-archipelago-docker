#!/bin/bash
cd /opt/Archipelago

cat <<EOF > factorio/data/server-settings.json
{
    "admins": ["$FACTORIO_ADMIN"]
}
EOF

/archi_factorio_expect.exp $ARCHIPELAGO_SERVER $ARCHIPELAGO_PORT