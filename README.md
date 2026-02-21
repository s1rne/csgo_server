# CS:GO Legacy Dedicated Server

Выделенный сервер CS:GO (Global Offensive) для игры с друзьями.
Работает с клиентами через ветку `csgo_legacy` в Steam, включая **macOS**.

## Требования к серверу

- **ОС:** Kali Linux / Debian / Ubuntu
- **RAM:** минимум 2 ГБ (рекомендуется 4 ГБ)
- **Диск:** ~30 ГБ свободного места
- **Сеть:** открытые порты 27015 UDP/TCP

## Быстрый старт

```bash
# 1. Сделать скрипты исполняемыми
chmod +x install.sh start.sh stop.sh update.sh status.sh firewall.sh

# 2. Установить сервер (зависимости + SteamCMD + серверные файлы)
./install.sh

# 3. Открыть порты в файрволе
./firewall.sh

# 4. Настроить сервер
nano cfg/server.cfg

# 5. Запустить
./start.sh
```

## Управление сервером

| Команда | Описание |
|---------|----------|
| `./start.sh` | Запуск сервера в screen-сессии |
| `./stop.sh` | Остановка сервера |
| `./status.sh` | Проверка статуса |
| `./update.sh` | Обновление серверных файлов |
| `screen -r csgo` | Подключение к консоли сервера |
| `Ctrl+A, D` | Выход из консоли без остановки |

## Настройка

Основной конфиг: `cfg/server.cfg`

- **hostname** — название сервера
- **sv_password** — пароль для входа (пустой = без пароля)
- **rcon_password** — пароль для удалённого управления
- **game_type / game_mode** — режим игры:
  - `0/0` — Casual
  - `0/1` — Competitive
  - `1/2` — Deathmatch
  - `1/0` — Arms Race
  - `1/1` — Demolition

Параметры запуска в `start.sh`:
- **PORT** — порт (по умолчанию 27015)
- **TICKRATE** — тикрейт (128)
- **MAXPLAYERS** — количество слотов (12)
- **MAP** — стартовая карта (de_dust2)

## Автозапуск через systemd

```bash
# Отредактируйте пути и пользователя в csgo-server.service
nano csgo-server.service

# Установите сервис
sudo cp csgo-server.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable csgo-server
sudo systemctl start csgo-server
```

## Подключение клиентов

### Windows / Linux
1. Steam → Counter-Strike 2 → Свойства → Бета-версии → `csgo_legacy`
2. Дождаться загрузки
3. Запустить CS:GO Legacy
4. Консоль (`~`): `connect <IP_сервера>:27015`

### macOS
1. Steam → Counter-Strike 2 → Свойства → Бета-версии → `csgo_legacy`
2. Запустить игру (выбрать Legacy версию)
3. Консоль (`~`): `connect <IP_сервера>:27015`

Если установлен пароль:
```
connect <IP_сервера>:27015; password <пароль>
```

## Запуск через Docker (альтернатива)

Если на сервере установлен Docker, можно запустить CS:GO одной командой без ручной установки SteamCMD и зависимостей.

### Требования

- Docker + Docker Compose
- ~30 ГБ для образа и серверных файлов
- Открытые порты 27015 UDP/TCP

### Запуск

```bash
# Запустить сервер (первый запуск скачает ~25 ГБ серверных файлов)
docker compose up -d

# Логи сервера
docker compose logs -f

# Остановить сервер
docker compose down

# Консоль сервера
docker exec -it csgo-server bash
```

### Настройка

Параметры задаются через переменные окружения в `docker-compose.yml`:

| Переменная | По умолчанию | Описание |
|---|---|---|
| `SRCDS_TOKEN` | пусто | GSLT токен (для интернета) |
| `SRCDS_RCONPW` | `changeme_rcon` | RCON пароль |
| `SRCDS_PW` | пусто | Пароль для входа |
| `SRCDS_TICKRATE` | `128` | Тикрейт |
| `SRCDS_MAXPLAYERS` | `12` | Макс. игроков |
| `SRCDS_STARTMAP` | `de_dust2` | Стартовая карта |
| `SRCDS_GAMETYPE` | `0` | Тип игры |
| `SRCDS_GAMEMODE` | `1` | Режим (1 = Competitive) |

Конфиг `cfg/server.cfg` монтируется в контейнер автоматически.

### Используемый образ

[cm2network/csgo](https://hub.docker.com/r/cm2network/csgo) — 1M+ загрузок на Docker Hub. Репозиторий архивирован (CS2 вышел), но образ работает стабильно, т.к. CS:GO Legacy больше не обновляется.

## Структура проекта

```
csgo_server/
├── install.sh            # Установка всего
├── start.sh              # Запуск сервера
├── stop.sh               # Остановка
├── update.sh             # Обновление файлов
├── status.sh             # Проверка статуса
├── firewall.sh           # Настройка портов
├── csgo-server.service   # Systemd unit
├── docker-compose.yml    # Docker-вариант запуска
├── cfg/
│   ├── server.cfg        # Конфигурация сервера
│   └── autoexec.cfg      # Автозапуск конфигов
├── steamcmd/             # SteamCMD (создаётся при установке)
└── server/               # Серверные файлы (создаётся при установке)
```
