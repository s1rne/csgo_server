#!/bin/bash

echo "Остановка CS:GO сервера..."

if screen -list | grep -q "csgo"; then
    screen -S csgo -X stuff "quit$(printf '\r')"
    sleep 2

    if screen -list | grep -q "csgo"; then
        screen -S csgo -X quit
        echo "Сессия screen принудительно завершена."
    else
        echo "Сервер остановлен."
    fi
else
    echo "Сервер не запущен (screen-сессия 'csgo' не найдена)."
fi
