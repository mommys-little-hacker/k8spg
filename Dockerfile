FROM postgres:10

ENV AWS_ACCESS_KEY_ID="" \
    AWS_SECRET_ACCESS_KEY="" \
    PGHOST="" \
    PGPORT=5432 \
    PGUSER="postgres" \
    PGPASSWORD=""

ADD https://github.com/aptible/supercronic/releases/download/v0.1.8/supercronic-linux-amd64 \
    /usr/local/bin/supercronic
ADD https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64 \
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
    && wget -q https://github.com/wal-g/wal-g/releases/download/v0.2.3/wal-g.linux-amd64.tar.gz -O - \
        | tar -xzO > /usr/local/bin/wal-g \
    && chmod 755 /usr/local/bin/wal-g \
        /usr/local/bin/supercronic \
        /usr/local/bin/gosu \
        /src/*.sh \
    && apt-get purge -y wget \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/
