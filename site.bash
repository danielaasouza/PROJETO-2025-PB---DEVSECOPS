#!/bin/bash

URL="http://localhost"
LOG="/var/log/monitoramento.log"
DATA=$(date '+%Y-%m-%d %H:%M:%S')

# Testa se o NGINX está respondendo
if curl -s --head "$URL" | grep "200 OK" > /dev/null; then
  echo "$DATA - OK" >> "$LOG"
else
  echo "$DATA - ERRO" >> "$LOG"

  # Envia alerta no Discord
  curl -X POST -H "Content-Type: application/json" \
    -d "{\"content\": \"Site fora do ar em $DATA\"}" \
    https://discord.com/api/webhooks/WEBHOOK_DISCORD
fi
