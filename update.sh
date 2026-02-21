#!/bin/bash
set -e

CSGO_DIR="$(cd "$(dirname "$0")" && pwd)"
STEAMCMD_DIR="$CSGO_DIR/steamcmd"
SERVER_DIR="$CSGO_DIR/server"

echo "=== Обновление CS:GO сервера ==="

# Остановить сервер, если запущен
if screen -list 2>/dev/null | grep -q "csgo"; then
    echo "Сервер запущен — останавливаю..."
    "$CSGO_DIR/stop.sh"
    sleep 3
fi

echo "Загрузка обновлений..."
"$STEAMCMD_DIR/steamcmd.sh" \
    +force_install_dir "$SERVER_DIR" \
    +login anonymous \
    +app_update 740 validate \
    +quit

# Повторно применить патч версии
STEAM_INF="$SERVER_DIR/csgo/steam.inf"
if [ -f "$STEAM_INF" ]; then
    sed -i 's/^ClientVersion=.*/ClientVersion=2000522/' "$STEAM_INF"
    sed -i 's/^ServerVersion=.*/ServerVersion=2000522/' "$STEAM_INF"
    echo "steam.inf обновлён для Legacy."
fi

# Вернуть конфиги
CONFIG_SRC="$CSGO_DIR/cfg"
CONFIG_DST="$SERVER_DIR/csgo/cfg"
if [ -f "$CONFIG_SRC/server.cfg" ]; then
    cp "$CONFIG_SRC/server.cfg" "$CONFIG_DST/server.cfg"
fi

echo ""
echo "Обновление завершено. Запустите сервер: ./start.sh"
