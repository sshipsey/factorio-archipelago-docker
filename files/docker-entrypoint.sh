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

./ArchipelagoFactorioClient <&0

SERVER_PID=$!

# Wait for the log file to be created
while [ ! -f /opt/Archipelago/logs/FactorioClient_*.txt ]; do
    sleep 1
done

( tail -f /opt/Archipelago/logs/FactorioClient_*.txt & ) | grep -q "Ready to connect to Archipelago via /connect"

echo "Sending multiworld connect command..."

script -q -c "printf '/connect ${ARCHIPELAGO_SERVER}:${ARCHIPELAGO_PORT}\n'" /proc/$SERVER_PID/fd/0

wait $SERVER_PID