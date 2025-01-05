#!/bin/bash
cd /opt/Archipelago

cat <<EOF > factorio/mods/mod-list.json
{
    "mods": [
      {
        "name": "base",
        "enabled": true
      },
      {
        "name": "elevated-rails",
        "enabled": false
      },
      {
        "name": "quality",
        "enabled": false
      },
      {
        "name": "space-age",
        "enabled": false
      }
    ]
}
EOF

/archi_factorio_expect.exp $ARCHIPELAGO_SERVER $ARCHIPELAGO_PORT