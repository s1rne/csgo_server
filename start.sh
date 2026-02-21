#!/bin/bash

CSGO_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_DIR="$CSGO_DIR/server"
SRCDS="$SERVER_DIR/srcds_run"

# --- Параметры запуска ---
PORT=27015
TICKRATE=128
MAXPLAYERS=12
MAP="de_dust2"

# game_type / game_mode:
#   Casual:        game_type 0, game_mode 0
#   Competitive:   game_type 0, game_mode 1
#   Deathmatch:    game_type 1, game_mode 2
#   Arms Race:     game_type 1, game_mode 0
#   Demolition:    game_type 1, game_mode 1
GAME_TYPE=0
GAME_MODE=1

# Если есть GSLT токен — вставить сюда (необязательно для LAN)
GSLT=""

if [ ! -f "$SRCDS" ]; then
    echo "ОШИБКА: srcds_run не найден в $SERVER_DIR"
    echo "Сначала запустите ./install.sh"
    exit 1
fi

GSLT_ARG=""
if [ -n "$GSLT" ]; then
    GSLT_ARG="+sv_setsteamaccount $GSLT"
fi

echo "=== Запуск CS:GO Legacy Server ==="
echo "Карта:    $MAP"
echo "Порт:     $PORT"
echo "Тикрейт:  $TICKRATE"
echo "Слотов:   $MAXPLAYERS"
echo "Режим:    game_type=$GAME_TYPE game_mode=$GAME_MODE"
echo ""
echo "Для остановки: ./stop.sh или Ctrl+C"
echo "=================================="

screen -dmS csgo "$SRCDS" \
    -game csgo \
    -console \
    -usercon \
    -port "$PORT" \
    -tickrate "$TICKRATE" \
    -maxplayers_override "$MAXPLAYERS" \
    +game_type "$GAME_TYPE" \
    +game_mode "$GAME_MODE" \
    +mapgroup mg_active \
    +map "$MAP" \
    +exec server.cfg \
    $GSLT_ARG \
    -ip 0.0.0.0

echo ""
echo "Сервер запущен в screen-сессии 'csgo'."
echo "Подключиться к консоли: screen -r csgo"
echo "Выйти из консоли без остановки: Ctrl+A, затем D"
echo ""
echo "Подключение к серверу: connect <ваш_IP>:$PORT"
