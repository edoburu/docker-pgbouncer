FROM alpine:3.13
ARG VERSION=1.16.0

# Inspiration from https://github.com/gmr/alpine-pgbouncer/blob/master/Dockerfile
# hadolint ignore=DL3003,DL3018
RUN \
  # security
  apk add -U --no-cache --upgrade busybox && \
  # Download
  apk add -U --no-cache autoconf autoconf-doc automake udns udns-dev curl gcc libc-dev libevent libevent-dev libtool make openssl-dev pkgconfig postgresql-client && \
  curl -o  /tmp/pgbouncer-$VERSION.tar.gz -L https://pgbouncer.github.io/downloads/files/$VERSION/pgbouncer-$VERSION.tar.gz && \
  cd /tmp && \
  # Unpack, compile
  tar xvfz /tmp/pgbouncer-$VERSION.tar.gz && \
  cd pgbouncer-$VERSION && \
  ./configure --prefix=/usr --with-udns && \
  make && \
  # Manual install
  cp pgbouncer /usr/bin && \
  mkdir -p /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer && \
  # entrypoint installs the configuration, allow to write as postgres user
  cp etc/pgbouncer.ini /etc/pgbouncer/pgbouncer.ini.example && \
  cp etc/userlist.txt /etc/pgbouncer/userlist.txt.example && \
  touch /etc/pgbouncer/userlist.txt && \
  addgroup -g 70 -S postgres 2>/dev/null && \
  adduser -u 70 -S -D -H -h /var/lib/postgresql -g "Postgres user" -s /bin/sh -G postgres postgres 2>/dev/null && \
  chown -R postgres /var/run/pgbouncer /etc/pgbouncer && \
  # Cleanup
  cd /tmp && \
  rm -rf /tmp/pgbouncer*  && \
  apk del --purge autoconf autoconf-doc automake udns-dev curl gcc libc-dev libevent-dev libtool make libressl-dev pkgconfig

COPY entrypoint.sh /entrypoint.sh
USER postgres
EXPOSE 5432
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]
