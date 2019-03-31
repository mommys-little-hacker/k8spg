FROM postgres:11

ENV SUPERCRONIC_VER="v0.1.8" \
    WALG_VER="v0.2.7" \
    GOSU_VER="1.11" \
    PGHOST="" \
    PGPORT=5432 \
    PGUSER="postgres" \
    PGPASSWORD=""

ADD https://github.com/aptible/supercronic/releases/download/$SUPERCRONIC_VER/supercronic-linux-amd64 \
    /usr/local/bin/supercronic
ADD https://github.com/tianon/gosu/releases/download/$GOSU_VER/gosu-amd64 \
    /usr/local/bin/gosu
COPY src /src
COPY conf/ /etc/postgresql

# Install wal-g and clean up
RUN set -e \
    && apt-get update \
    && apt-get install -f -y --no-install-recommends \
        wget \
        ca-certificates \
        gettext-base \
    && wget -q https://github.com/wal-g/wal-g/releases/download/$WALG_VER/wal-g.linux-amd64.tar.gz -O - \
        | tar -xzO > /usr/local/bin/wal-g \
    && chmod 755 /usr/local/bin/wal-g \
        /usr/local/bin/supercronic \
        /usr/local/bin/gosu \
        /src/*.sh \
    && apt-get purge -y wget \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/
