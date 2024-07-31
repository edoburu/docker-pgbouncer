FROM alpine:3.20 AS build
ARG VERSION=1.23.0

# Inspiration from https://github.com/gmr/alpine-pgbouncer/blob/master/Dockerfile
# hadolint ignore=DL3003,DL3018
RUN apk add --no-cache autoconf autoconf-doc automake c-ares-dev curl gcc git libc-dev libevent-dev libtool make openssl-dev pandoc pkgconfig

# build version for release
RUN curl -sS -o /pgbouncer.tar.gz -L https://pgbouncer.github.io/downloads/files/$VERSION/pgbouncer-$VERSION.tar.gz && \
  tar -xzf /pgbouncer.tar.gz && mv /pgbouncer-$VERSION /pgbouncer

# build latest from git for test
# RUN git clone https://github.com/pgbouncer/pgbouncer.git && cd pgbouncer && \
#   git fetch origin pull/1120/head:test && git checkout test && \
#   git submodule init && git submodule update && ./autogen.sh

RUN cd /pgbouncer && ./configure --prefix=/usr --with-cares && make

FROM alpine:3.20 AS runtime

RUN apk add --no-cache busybox c-ares libevent postgresql-client && \
  mkdir -p /etc/pgbouncer /var/log/pgbouncer /var/run/pgbouncer && \
  touch /etc/pgbouncer/userlist.txt && \
  chown -R postgres /var/log/pgbouncer /var/run/pgbouncer /etc/pgbouncer

COPY entrypoint.sh /entrypoint.sh
COPY --from=build /pgbouncer/pgbouncer /usr/bin
COPY --from=build /pgbouncer/etc/pgbouncer.ini /etc/pgbouncer/pgbouncer.ini.example
COPY --from=build /pgbouncer/etc/userlist.txt /etc/pgbouncer/userlist.txt.example
EXPOSE 5432
USER postgres
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]
