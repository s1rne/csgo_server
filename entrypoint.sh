#!/bin/bash
set -e

SERVER_DIR="/home/steam/csgo-server"
CSGO_DIR="$SERVER_DIR/csgo"
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

# --- 1. Установка CS:GO ---
echo "=== CS:GO Legacy Server ==="
echo "[1/4] Проверка серверных файлов..."

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
        echo "Серверные файлы OK."
        break
    fi

    echo "srcds_run не найден, повторяю..."
    sleep 5
done

if [ ! -f "$SERVER_DIR/srcds_run" ]; then
    echo "ОШИБКА: не удалось установить сервер после $MAX_ATTEMPTS попыток."
    exit 1
fi

# --- 2. steamclient.so симлинк ---
mkdir -p /home/steam/.steam/sdk32
ln -sf /home/steam/steamcmd/linux32/steamclient.so /home/steam/.steam/sdk32/steamclient.so

# --- 3. Патч версии для совместимости с клиентом ---
echo "[2/4] Патч steam.inf..."
STEAM_INF="$CSGO_DIR/steam.inf"
if [ -f "$STEAM_INF" ]; then
    sed -i 's/^ClientVersion=.*/ClientVersion=1575/' "$STEAM_INF"
    sed -i 's/^ServerVersion=.*/ServerVersion=1575/' "$STEAM_INF"
    echo "Версия: 1575."
fi

# --- 4. Metamod + SourceMod + NoLobbyReservation ---
echo "[3/4] Проверка плагинов..."
ADDONS_DIR="$CSGO_DIR/addons"
SM_DIR="$ADDONS_DIR/sourcemod"

if [ ! -d "$ADDONS_DIR/metamod" ]; then
    echo "Установка Metamod:Source..."
    curl -sSL "https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1148-linux.tar.gz" \
        | tar -xzf - -C "$CSGO_DIR"
fi

if [ ! -d "$SM_DIR" ]; then
    echo "Установка SourceMod..."
    curl -sSL "https://sm.alliedmods.net/smdrop/1.11/sourcemod-1.11.0-git6968-linux.tar.gz" \
        | tar -xzf - -C "$CSGO_DIR"
fi

PLUGIN_DIR="$SM_DIR/plugins"
GAMEDATA_DIR="$SM_DIR/gamedata"
SCRIPTING_DIR="$SM_DIR/scripting"
REPO_BASE="https://raw.githubusercontent.com/eldoradoel/NoLobbyReservation/master/csgo/addons/sourcemod"

mkdir -p "$GAMEDATA_DIR"

if [ ! -f "$PLUGIN_DIR/nolobbyreservation.smx" ]; then
    echo "Установка NoLobbyReservation..."

    curl -sSL "$REPO_BASE/gamedata/nolobbyreservation.games.txt" \
        -o "$GAMEDATA_DIR/nolobbyreservation.games.txt"

    curl -sSL "$REPO_BASE/scripting/nolobbyreservation.sp" \
        -o "$SCRIPTING_DIR/nolobbyreservation.sp"

    cd "$SCRIPTING_DIR"
    chmod +x spcomp
    ./spcomp nolobbyreservation.sp -o "$PLUGIN_DIR/nolobbyreservation.smx"
    echo "NoLobbyReservation OK."
fi

echo "[4/4] Плагины готовы."

# --- 5. Запуск ---
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
    -nomaster \
    -norestart \
    -insecure \
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
