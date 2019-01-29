FROM postgres:10.4

ENV AWS_ACCESS_KEY_ID="" \
    AWS_SECRET_ACCESS_KEY="" \
    PGHOST="" \
    PGPORT=5432 \
    PGUSER="postgres" \
    PGPASSWORD=""

COPY src /src
COPY conf/ /etc/postgresql

# Install wal-g and clean up
RUN apt-get update \
    && apt-get install -f -y --no-install-recommends \
        cron \
        wget \
        ca-certificates \
        gettext-base \
    && wget -q https://github.com/wal-g/wal-g/releases/download/v0.2.3/wal-g.linux-amd64.tar.gz -O - \
    | tar -xzO > /usr/local/bin/wal-g \
    && chmod 755 /usr/local/bin/wal-g \
        /src/*.sh \
    && ln -rsf /etc/postgresql/crontab /etc/crontab \
    && apt-get purge -y wget \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/
