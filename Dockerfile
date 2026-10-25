# Hytale yolk for Pterodactyl / Pelican
# Based on Xytronix/yolks@hytale (games/hytale, commit 5d910a0, 2026-10-24),
# the source of pterodactyl/yolks#71. MIT licensed.

FROM        --platform=$TARGETOS/$TARGETARCH eclipse-temurin:25-jdk-noble

LABEL       org.opencontainers.image.description="Hytale server yolk: Python launcher, OAuth2 device auth, toggleable auto-update, server-file backups" \
            org.opencontainers.image.licenses=MIT

RUN         apt-get update -y \
            && apt-get install -y --no-install-recommends \
                curl \
                ca-certificates \
                fontconfig \
                tzdata \
                tini \
                locales \
                unzip \
                tar \
                zip \
                sqlite3 \
                git \
                openssl \
                lsof \
                file \
                python3-minimal \
                python3-requests \
            && apt-get clean \
            && rm -rf /var/lib/apt/lists/*

RUN         sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
            && locale-gen
ENV         LANG=en_US.UTF-8 \
            LANGUAGE=en_US:en \
            LC_ALL=en_US.UTF-8

RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL  SIGINT

COPY        --chown=container:container ./entrypoint.py /entrypoint.py
RUN         chmod +x /entrypoint.py
ENTRYPOINT  ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.py"]
