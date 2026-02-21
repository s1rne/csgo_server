#!/bin/bash
set -e

CSGO_DIR="$(cd "$(dirname "$0")" && pwd)"
STEAMCMD_DIR="$CSGO_DIR/steamcmd"
SERVER_DIR="$CSGO_DIR/server"

echo "=== Установка CS:GO Legacy Dedicated Server ==="
echo "Директория: $CSGO_DIR"
echo ""

# --- Зависимости ---
echo "[1/4] Установка зависимостей..."
sudo dpkg --add-architecture i386
sudo apt-get update -y
sudo apt-get install -y \
    lib32gcc-s1 \
    lib32stdc++6 \
    libc6-i386 \
    lib32z1 \
    curl \
    wget \
    ca-certificates \
    screen \
    tar

# --- SteamCMD ---
echo ""
echo "[2/4] Установка SteamCMD..."
mkdir -p "$STEAMCMD_DIR"
cd "$STEAMCMD_DIR"

if [ ! -f "$STEAMCMD_DIR/steamcmd.sh" ]; then
    wget -q "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
    tar -xzf steamcmd_linux.tar.gz
    rm steamcmd_linux.tar.gz
    echo "SteamCMD установлен."
else
    echo "SteamCMD уже установлен, пропускаю."
fi

# --- Серверные файлы CS:GO ---
echo ""
echo "[3/4] Загрузка серверных файлов CS:GO (App ID 740)..."
echo "Это может занять 20-30 минут при первой загрузке."
mkdir -p "$SERVER_DIR"

"$STEAMCMD_DIR/steamcmd.sh" \
    +force_install_dir "$SERVER_DIR" \
    +login anonymous \
    +app_update 740 validate \
    +quit

# --- Патч версии для Legacy ---
echo ""
echo "[4/4] Применение патча steam.inf для Legacy совместимости..."
STEAM_INF="$SERVER_DIR/csgo/steam.inf"
if [ -f "$STEAM_INF" ]; then
    sed -i 's/^ClientVersion=.*/ClientVersion=2000522/' "$STEAM_INF"
    sed -i 's/^ServerVersion=.*/ServerVersion=2000522/' "$STEAM_INF"
    echo "steam.inf обновлён."
else
    echo "ВНИМАНИЕ: $STEAM_INF не найден. Проверьте загрузку."
fi

# --- Копирование конфигов ---
echo ""
echo "=== Копирование конфигурации ==="
CONFIG_SRC="$CSGO_DIR/cfg"
CONFIG_DST="$SERVER_DIR/csgo/cfg"

mkdir -p "$CONFIG_DST"

if [ -f "$CONFIG_SRC/server.cfg" ]; then
    cp "$CONFIG_SRC/server.cfg" "$CONFIG_DST/server.cfg"
    echo "server.cfg скопирован."
fi

if [ -f "$CONFIG_SRC/autoexec.cfg" ]; then
    cp "$CONFIG_SRC/autoexec.cfg" "$CONFIG_DST/autoexec.cfg"
    echo "autoexec.cfg скопирован."
fi

echo ""
echo "=========================================="
echo "  Установка завершена!"
echo "=========================================="
echo ""
echo "Следующие шаги:"
echo "  1. Отредактируйте cfg/server.cfg (имя сервера, пароль и т.д.)"
echo "  2. Запустите сервер: ./start.sh"
echo "  3. Подключение: connect <ваш_IP>:27015"
echo ""
echo "Если нужен пароль, клиенты подключаются:"
echo "  connect <ваш_IP>:27015; password <пароль>"
echo ""
