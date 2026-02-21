#!/bin/bash

echo "=== Настройка файрвола для CS:GO сервера ==="

# CS:GO использует порт 27015 (UDP основной, TCP для RCON)
sudo iptables -A INPUT -p udp --dport 27015 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 27015 -j ACCEPT

# Steam query port (обычно 27015, но может быть 27016)
sudo iptables -A INPUT -p udp --dport 27016 -j ACCEPT

# Steam auth
sudo iptables -A INPUT -p udp --dport 26900:27030 -j ACCEPT

echo "Порты открыты."
echo ""
echo "Для сохранения правил после перезагрузки:"
echo "  sudo apt-get install iptables-persistent"
echo "  sudo netfilter-persistent save"
