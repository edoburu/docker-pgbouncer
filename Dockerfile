FROM alpine:3.13

# Inspiration from https://github.com/gmr/alpine-pgbouncer/blob/master/Dockerfile
# hadolint ignore=DL3003,DL3018

ENV PANDOC_VERSION 2.0.2
ENV PANDOC_DOWNLOAD_URL https://github.com/jgm/pandoc/archive/$PANDOC_VERSION.tar.gz
ENV PANDOC_DOWNLOAD_SHA512 5830e0d8670a0bf80d9e8a84412d9f3782d5a6d9cf384fc7a853ad7f4e41a94ed51322ca73b86ad93528a7ec82eaf343704db811ece3455e68f1049761544a88
ENV PANDOC_ROOT /usr/local/pandoc

# pandoc
RUN apk add --no-cache \
    gmp \
    libffi \
    && apk add --no-cache --virtual build-dependencies \
    --repository "http://nl.alpinelinux.org/alpine/edge/community" \
    ghc \
    cabal \
    linux-headers \
    musl-dev \
    zlib-dev \
    curl \
    && mkdir -p /pandoc-build && cd /pandoc-build \
    && curl -fsSL "$PANDOC_DOWNLOAD_URL" -o pandoc.tar.gz \
    && echo "$PANDOC_DOWNLOAD_SHA512  pandoc.tar.gz" | sha512sum -c - \
    && tar -xzf pandoc.tar.gz && rm -f pandoc.tar.gz \
    && ( cd pandoc-$PANDOC_VERSION && cabal update && cabal install --only-dependencies \
    && cabal configure --prefix=$PANDOC_ROOT \
    && cabal build \
    && cabal copy \
    && cd .. ) \
    && rm -Rf pandoc-$PANDOC_VERSION/ \
    && apk del --purge build-dependencies \
    && rm -Rf /root/.cabal/ /root/.ghc/ \
    && cd / && rm -Rf /pandoc-build

    ENV PATH $PATH:$PANDOC_ROOT/bin

RUN \
  # security
  apk add -U --no-cache --upgrade busybox && \
  # Download
  apk add -U --no-cache autoconf autoconf-doc automake udns udns-dev curl gcc libc-dev libevent libevent-dev libtool make openssl-dev pkgconfig postgresql-client git pandoc-doc && \
  git clone https://github.com/pgbouncer/pgbouncer && \
  cd /pgbouncer && git submodule init && git submodule update && ./autogen.sh && ./configure --prefix=/usr --with-udns && \
  # Compile
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
  rm -rf /pgbouncer*  && \
  apk del --purge autoconf autoconf-doc automake udns-dev curl gcc libc-dev libevent-dev libtool make libressl-dev pkgconfig git pandoc-doc

COPY entrypoint.sh /entrypoint.sh
USER postgres
EXPOSE 5432
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]
