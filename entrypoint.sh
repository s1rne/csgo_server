#!/bin/bash
set -e

SERVER_DIR="/home/steam/csgo-server"
STEAMCMD="/home/steam/steamcmd/steamcmd.sh"

PORT="${SRCDS_PORT:-27015}"
TICKRATE="${SRCDS_TICKRATE:-128}"
MAXPLAYERS="${SRCDS_MAXPLAYERS:-12}"
MAP="${SRCDS_STARTMAP:-de_dust2}"
GAME_TYPE="${SRCDS_GAMETYPE:-0}"
GAME_MODE="${SRCDS_GAMEMODE:-1}"
MAPGROUP="${SRCDS_MAPGROUP:-mg_active}"
GSLT="${SRCDS_TOKEN:-}"
FPSMAX="${SRCDS_FPSMAX:-300}"

mkdir -p "$SERVER_DIR"

echo "=== CS:GO Legacy Server ==="
echo "Проверка/установка серверных файлов..."

ATTEMPTS=0
MAX_ATTEMPTS=5

while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    ATTEMPTS=$((ATTEMPTS + 1))
    echo "Попытка $ATTEMPTS из $MAX_ATTEMPTS..."

    "$STEAMCMD" \
        +force_install_dir "$SERVER_DIR" \
        +login anonymous \
        +app_update 740 \
        +quit

    if [ -f "$SERVER_DIR/srcds_run" ]; then
        echo "Серверные файлы установлены."
        break
    fi

    echo "srcds_run не найден, повторяю..."
    sleep 5
done

if [ ! -f "$SERVER_DIR/srcds_run" ]; then
    echo "ОШИБКА: не удалось установить сервер после $MAX_ATTEMPTS попыток."
    exit 1
fi

STEAM_INF="$SERVER_DIR/csgo/steam.inf"
if [ -f "$STEAM_INF" ]; then
    sed -i 's/^ClientVersion=.*/ClientVersion=2000522/' "$STEAM_INF"
    sed -i 's/^ServerVersion=.*/ServerVersion=2000522/' "$STEAM_INF"
    echo "steam.inf пропатчен для Legacy."
fi

GSLT_ARG=""
if [ -n "$GSLT" ]; then
    GSLT_ARG="+sv_setsteamaccount $GSLT"
fi

echo ""
echo "=== Запуск CS:GO Legacy Server ==="
echo "Карта:    $MAP"
echo "Порт:     $PORT"
echo "Тикрейт:  $TICKRATE"
echo "Слотов:   $MAXPLAYERS"
echo "=================================="

exec "$SERVER_DIR/srcds_run" \
    -game csgo \
    -console \
    -usercon \
    -port "$PORT" \
    -tickrate "$TICKRATE" \
    -maxplayers_override "$MAXPLAYERS" \
    +fps_max "$FPSMAX" \
    +game_type "$GAME_TYPE" \
    +game_mode "$GAME_MODE" \
    +mapgroup "$MAPGROUP" \
    +map "$MAP" \
    +exec server.cfg \
    $GSLT_ARG \
    -ip 0.0.0.0
