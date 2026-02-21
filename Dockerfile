FROM debian:bullseye-slim

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        lib32gcc-s1 \
        lib32stdc++6 \
        libc6-i386 \
        lib32z1 \
        curl \
        wget \
        ca-certificates \
        tar \
        locales && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m -s /bin/bash steam

USER steam
WORKDIR /home/steam

RUN mkdir -p /home/steam/steamcmd && \
    cd /home/steam/steamcmd && \
    wget -q "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" && \
    tar -xzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz

COPY --chown=steam:steam entrypoint.sh /home/steam/entrypoint.sh
RUN chmod +x /home/steam/entrypoint.sh

EXPOSE 27015/tcp 27015/udp 27020/udp

ENTRYPOINT ["/home/steam/entrypoint.sh"]
