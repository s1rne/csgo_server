#!/bin/bash

echo "=== Статус CS:GO сервера ==="
echo ""

if screen -list 2>/dev/null | grep -q "csgo"; then
    echo "Состояние: ЗАПУЩЕН"
    echo ""
    echo "Screen-сессия:"
    screen -list | grep csgo
    echo ""
    echo "Процесс srcds:"
    ps aux | grep srcds | grep -v grep || echo "  (процесс не найден)"
    echo ""
    echo "Порт 27015:"
    ss -ulnp | grep 27015 || echo "  (порт не прослушивается)"
else
    echo "Состояние: ОСТАНОВЛЕН"
fi

echo ""
