#!/bin/sh
set -e

echo "[init-owner] Waiting for n8n-main at http://127.0.0.1:5678/healthz..."
for i in $(seq 1 60); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:5678/healthz || true)
  if [ "$STATUS" = "200" ]; then
    echo "[init-owner] n8n-main is healthy!"
    break
  fi
  sleep 2
done

echo "[init-owner] Checking if owner setup is needed..."
SETUP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:5678/rest/owner/setup || true)
echo "[init-owner] Endpoint response status: $SETUP_STATUS"

if [ "$SETUP_STATUS" != "404" ] && [ "$SETUP_STATUS" != "403" ]; then
  echo "[init-owner] Provisioning admin account admin@standartmaster.ru..."
  RES=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST http://127.0.0.1:5678/rest/owner/setup \
    -H "Content-Type: application/json" \
    -d '{
      "email": "admin@standartmaster.ru",
      "password": "Cnhtc101%",
      "firstName": "Admin",
      "lastName": "StandartMaster"
    }' || true)
  echo "[init-owner] Result: $RES"
else
  echo "[init-owner] Owner account already initialized or endpoint protected."
fi

echo "[init-owner] Done!"
